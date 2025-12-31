import AsyncAlgorithms
import DiskArbitration
import Foundation
import IOKit
import IOKit.storage
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

    let targetVolumeUUIDs = [
      "830EBDAC-2B79-41AB-AA1E-6F5B05A8ADAB"  // SSD
    ]

    private let timer: AsyncTimerSequence<ContinuousClock>
    private var timerTask: Task<Void, Never>?
    private var unmountingVolumeUUIDs: Set<String> = []
    private let daSession: DASession

    struct MountedVolume: Identifiable {
      let id: String
      let name: String
      let path: String
      let isMounted: Bool
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

    func fetchMountedVolumes() -> [MountedVolume] {
      guard let matching = IOServiceMatching(kIOMediaClass) else {
        logger.error("IOServiceMatching failed")
        return []
      }

      var iterator: io_iterator_t = 0
      let result = IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator)
      guard result == KERN_SUCCESS else {
        logger.error("IOServiceGetMatchingServices failed: \(result)")
        return []
      }

      defer {
        IOObjectRelease(iterator)
      }

      var resultsByUUID: [String: MountedVolume] = [:]

      while case let service = IOIteratorNext(iterator), service != 0 {
        defer {
          IOObjectRelease(service)
        }

        guard let disk = DADiskCreateFromIOMedia(kCFAllocatorDefault, daSession, service),
          let description = DADiskCopyDescription(disk) as? [CFString: Any]
        else {
          continue
        }

        if let mountable = description[kDADiskDescriptionVolumeMountableKey] as? Bool,
          !mountable
        {
          continue
        }

        guard let rawUUID = description[kDADiskDescriptionVolumeUUIDKey] else {
          continue
        }

        let uuid = volumeUUIDString(from: rawUUID)
        if uuid.isEmpty {
          continue
        }

        let name =
          (description[kDADiskDescriptionVolumeNameKey] as? String)
          ?? (description[kDADiskDescriptionMediaBSDNameKey] as? String)
          ?? uuid
        let path = (description[kDADiskDescriptionVolumePathKey] as? URL)?.path ?? ""
        let isMounted = !path.isEmpty

        let volume = MountedVolume(id: uuid, name: name, path: path, isMounted: isMounted)

        if let existing = resultsByUUID[uuid] {
          if !existing.isMounted && isMounted {
            resultsByUUID[uuid] = volume
          }
        } else {
          resultsByUUID[uuid] = volume
        }
      }

      return resultsByUUID.values.sorted {
        $0.name.localizedStandardCompare($1.name) == .orderedAscending
      }
    }

    private func volumeUUIDString(from rawUUID: Any) -> String {
      let rawAsCF = rawUUID as CFTypeRef
      if CFGetTypeID(rawAsCF) == CFUUIDGetTypeID() {
        // swiftlint:disable:next force_cast
        let cfuuid = rawAsCF as! CFUUID
        return CFUUIDCreateString(kCFAllocatorDefault, cfuuid) as String
      }

      if let uuidString = rawUUID as? String {
        return uuidString
      }

      return ""
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
