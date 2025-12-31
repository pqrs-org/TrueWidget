import AsyncAlgorithms
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

    let targetVolumeUUIDs = [
      "830EBDAC-2B79-41AB-AA1E-6F5B05A8ADAB"  // SSD
    ]

    private let timer: AsyncTimerSequence<ContinuousClock>
    private var timerTask: Task<Void, Never>?
    private var unmountingVolumeUUIDs: Set<String> = []
    private let daSession: DASession

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
