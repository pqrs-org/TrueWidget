import AsyncAlgorithms
import Darwin
import DiskArbitration
import Foundation
import OSLog
import SwiftUI

public struct ExtraFeatures {
  @MainActor
  final class AutoVolumeUnmounter {
    private let logger = Logger(
      subsystem: Bundle.main.bundleIdentifier ?? "unknown",
      category: String(describing: AutoVolumeUnmounter.self))

    static let shared = AutoVolumeUnmounter()

    @AppStorage("autoVolumeUnmountRecords") private var autoVolumeUnmountRecordsData: Data = Data()

    @CodableAppStorage("autoVolumeUnmounterTargetVolumeUUIDs") private var targetVolumeUUIDs:
      [String] = []

    private let timer: AsyncTimerSequence<ContinuousClock>
    private var timerTask: Task<Void, Never>?
    private var unmountingVolumeUUIDs: Set<String> = []
    private let daSession: DASession

    struct AutoUnmountCandidateVolume: Identifiable {
      let id: String
      let name: String
      let path: String
      let roles: [String]
    }

    init() {
      guard let session = DASessionCreate(kCFAllocatorDefault) else {
        fatalError("DASessionCreate failed")
      }
      daSession = session
      DASessionSetDispatchQueue(daSession, DispatchQueue.main)

      timer = AsyncTimerSequence(
        interval: .seconds(5),
        clock: .continuous
      )
    }

    @MainActor deinit {
      stop()
    }

    func start() {
      guard timerTask == nil else {
        return
      }

      timerTask = Task { @MainActor in
        checkAndUnmount()

        for await _ in timer {
          checkAndUnmount()
        }
      }
    }

    func stop() {
      timerTask?.cancel()
      timerTask = nil
    }

    private func checkAndUnmount() {
      guard let bootTimeEpoch = currentBootTimeEpoch() else {
        logger.error("kern.boottime failed")
        return
      }

      let resourceKeys: Set<URLResourceKey> = [
        .volumeUUIDStringKey
      ]

      let mountedVolumes =
        FileManager.default.mountedVolumeURLs(
          includingResourceValuesForKeys: Array(resourceKeys),
          options: []
        ) ?? []

      let unmountRecords = autoVolumeUnmountRecords

      for volumeURL in mountedVolumes {
        guard let values = try? volumeURL.resourceValues(forKeys: resourceKeys),
          let uuid = values.volumeUUIDString
        else {
          continue
        }

        guard targetVolumeUUIDs.contains(uuid) else {
          continue
        }

        if let lastUnmount = unmountRecords[uuid],
          lastUnmount >= bootTimeEpoch
        {
          continue
        }

        guard !unmountingVolumeUUIDs.contains(uuid) else {
          continue
        }

        unmountingVolumeUUIDs.insert(uuid)
        unmount(volumeURL: volumeURL, uuid: uuid)
      }
    }

    private func unmount(volumeURL: URL, uuid: String) {
      guard
        let disk = DADiskCreateFromVolumePath(
          kCFAllocatorDefault,
          daSession,
          volumeURL as CFURL
        )
      else {
        logger.error("DADiskCreateFromVolumePath failed url:\(volumeURL) uuid:\(uuid)")
        unmountingVolumeUUIDs.remove(uuid)
        return
      }

      logger.info("unmount url:\(volumeURL) uuid:\(uuid)")

      let context = UnmountContext(owner: self, uuid: uuid)
      let unmanaged = Unmanaged.passRetained(context)

      DADiskUnmount(
        disk,
        DADiskUnmountOptions(kDADiskUnmountOptionDefault),
        AutoVolumeUnmounter.unmountCallback,
        unmanaged.toOpaque()
      )
    }

    private final class UnmountContext {
      weak var owner: AutoVolumeUnmounter?
      let uuid: String

      init(owner: AutoVolumeUnmounter, uuid: String) {
        self.owner = owner
        self.uuid = uuid
      }
    }

    private static let unmountCallback: DADiskUnmountCallback = { _, dissenter, context in
      guard let context else {
        return
      }

      let unmountContext = Unmanaged<UnmountContext>.fromOpaque(context).takeRetainedValue()
      let owner = unmountContext.owner
      let uuid = unmountContext.uuid

      let succeeded = (dissenter == nil)
      let errorMessage =
        dissenter.map {
          let status = AutoVolumeUnmounter.dissenterStatus(dissenter: $0)
          let reason = AutoVolumeUnmounter.dissenterStatusString(dissenter: $0)
          return "DADiskUnmount failed uuid:\(uuid) status:\(status) reason:\(reason)"
        } ?? ""

      Task { @MainActor in
        if succeeded {
          owner?.markUnmounted(uuid: uuid)
        } else {
          owner?.logger.error("\(errorMessage)")
        }
        owner?.unmountingVolumeUUIDs.remove(uuid)
      }
    }

    private var autoVolumeUnmountRecords: [String: TimeInterval] {
      get {
        guard !autoVolumeUnmountRecordsData.isEmpty,
          let decoded = try? JSONDecoder().decode(
            [String: TimeInterval].self, from: autoVolumeUnmountRecordsData)
        else {
          return [:]
        }
        return decoded
      }
      set {
        if let data = try? JSONEncoder().encode(newValue) {
          autoVolumeUnmountRecordsData = data
        }
      }
    }

    private func markUnmounted(uuid: String) {
      var records = autoVolumeUnmountRecords
      records[uuid] = Date().timeIntervalSince1970
      autoVolumeUnmountRecords = records
    }

    func resetAutoVolumeUnmountRecords() {
      autoVolumeUnmountRecords = [:]
    }

    func autoUnmountCandidateVolumes() -> [AutoUnmountCandidateVolume] {
      // We want to exclude volumes like EFI, Recovery, and Update from the result.
      // To distinguish those volumes, we need to check the APFS Volume Roles.
      // The only reliable source for APFS Volume Roles is `diskutil apfs list -plist`.
      // Therefore, we build the volume list using diskutil and then append additional details via DiskArbitration.

      guard let data = diskutilApfsListPlist() else {
        return []
      }

      return parseDiskutilApfsList(data: data)
    }

    private func diskutilApfsListPlist() -> Data? {
      let command = "/usr/sbin/diskutil"
      guard FileManager.default.fileExists(atPath: command) else {
        logger.error("diskutil not found")
        return nil
      }

      let process = Process()
      process.launchPath = command
      process.arguments = [
        "apfs",
        "list",
        "-plist",
      ]
      process.environment = [
        "LANG": "C",
        "LC_ALL": "C",
      ]

      let pipe = Pipe()
      process.standardOutput = pipe
      process.standardError = Pipe()

      do {
        try process.run()
        process.waitUntilExit()
      } catch {
        logger.error("diskutil failed to run")
        return nil
      }

      guard process.terminationStatus == 0 else {
        logger.error("diskutil failed status:\(process.terminationStatus)")
        return nil
      }

      guard let data = try? pipe.fileHandleForReading.readToEnd(), !data.isEmpty else {
        logger.error("diskutil returned empty plist")
        return nil
      }

      return data
    }

    private func parseDiskutilApfsList(data: Data) -> [AutoUnmountCandidateVolume] {
      var resultsByUUID: [String: AutoUnmountCandidateVolume] = [:]
      let excludedRoles: Set<String> = [
        "Preboot",
        "xART",
        "Hardware",
        "Recovery",
        "Update",
      ]

      guard
        let plist = try? PropertyListSerialization.propertyList(
          from: data,
          options: [],
          format: nil
        ),
        let root = plist as? [String: Any]
      else {
        logger.error("diskutil plist parse failed")
        return []
      }

      // The root volume is treated differently from other volumes,
      // and DiskArbitration does not provide its volume path.
      // Therefore, we need to obtain the root volume information using a different method and exclude it from the results.
      let rootBSDNames = normalizedVolumeBSDNames(rootVolumeBSDName())

      for container in root["Containers"] as? [[String: Any]] ?? [] {
        for volume in (container["Volumes"] as? [[String: Any]]) ?? [] {
          guard let uuid = (volume["APFSVolumeUUID"] as? String) else {
            continue
          }

          let roles = volume["Roles"] as? [String] ?? []
          if roles.contains(where: { excludedRoles.contains($0) }) {
            continue
          }

          let deviceIdentifier = (volume["DeviceIdentifier"] as? String) ?? ""
          if rootBSDNames.contains(deviceIdentifier) {
            continue
          }

          let daInfo =
            deviceIdentifier.isEmpty
            ? (name: nil, path: nil)
            : diskArbitrationVolumeInfo(bsdName: deviceIdentifier)

          let path = daInfo.path ?? ""
          if path == "/"
            || path.hasPrefix("/Library/")  // /Library/Developer/CoreSimulator/...
            || path.hasPrefix("/private/")  // /private/var/run/com.apple.security.cryptexd/...
            || path.hasPrefix("/System/")  // /System/Volumes/...
          {
            continue
          }

          let mountedVolume = AutoUnmountCandidateVolume(
            id: uuid,
            name: daInfo.name
              ?? (volume["Name"] as? String)
                ?? (deviceIdentifier.isEmpty ? uuid : deviceIdentifier),
            path: path,
            roles: roles
          )

          resultsByUUID[uuid] = mountedVolume
        }
      }

      return resultsByUUID.values.sorted {
        $0.name.localizedStandardCompare($1.name) == .orderedAscending
      }
    }

    private func diskArbitrationVolumeInfo(bsdName: String) -> (name: String?, path: String?) {
      guard let disk = DADiskCreateFromBSDName(kCFAllocatorDefault, daSession, bsdName) else {
        logger.error("DADiskCreateFromBSDName failed: \(bsdName)")
        return (nil, nil)
      }

      guard let description = DADiskCopyDescription(disk) as? [CFString: Any] else {
        return (nil, nil)
      }

      let name = description[kDADiskDescriptionVolumeNameKey] as? String
      let path = (description[kDADiskDescriptionVolumePathKey] as? URL)?.path
      return (name, path)
    }

    private func rootVolumeBSDName() -> String? {
      var stats = statfs()
      guard statfs("/", &stats) == 0 else {
        logger.error("statfs failed for /")
        return nil
      }

      let device = withUnsafePointer(to: &stats.f_mntfromname.0) {
        String(cString: $0)
      }
      if device.hasPrefix("/dev/") {
        return String(device.dropFirst(5))
      }
      return device.isEmpty ? nil : device
    }

    // The volume BSD name is normally in the diskXsY format (e.g., disk3s1).
    // However, under some conditions it can appear as diskXsYsZ.
    // (We could not find official documentation, but it tends to happen for snapshot-based mounts.)
    // DeviceIdentifier from `diskutil apfs list -plist` always uses the diskXsY format.
    // Therefore, if the BSD name is diskXsYsZ, include the diskXsY form as well so we can compare them.
    private func normalizedVolumeBSDNames(_ rootBSDName: String?) -> Set<String> {
      guard let rootBSDName, !rootBSDName.isEmpty else {
        return []
      }

      var names: Set<String> = [rootBSDName]
      let pattern = "^(disk\\d+s\\d+)s\\d+$"
      if let regex = try? NSRegularExpression(pattern: pattern),
        let match = regex.firstMatch(
          in: rootBSDName,
          range: NSRange(rootBSDName.startIndex..., in: rootBSDName)
        ),
        match.numberOfRanges > 1,
        let baseRange = Range(match.range(at: 1), in: rootBSDName)
      {
        names.insert(String(rootBSDName[baseRange]))
      }

      return names
    }

    private func currentBootTimeEpoch() -> TimeInterval? {
      var bootTime = timeval()
      var size = MemoryLayout<timeval>.size

      let result = sysctlbyname("kern.boottime", &bootTime, &size, nil, 0)
      if result != 0 {
        return nil
      }

      return TimeInterval(bootTime.tv_sec)
    }

    private static func dissenterStatus(dissenter: DADissenter) -> Int {
      let status = DADissenterGetStatus(dissenter)
      return Int(status)
    }

    private static func dissenterStatusString(dissenter: DADissenter) -> String {
      guard let cfString = DADissenterGetStatusString(dissenter) else {
        return "unknown"
      }
      return String(cfString)
    }
  }
}
