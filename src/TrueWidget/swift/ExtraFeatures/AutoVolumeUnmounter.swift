import AsyncAlgorithms
import DiskArbitration
import Foundation
import OSLog

public struct ExtraFeatures {
  @MainActor
  final class AutoVolumeUnmounter {
    private let logger = Logger(
      subsystem: Bundle.main.bundleIdentifier ?? "unknown",
      category: String(describing: AutoVolumeUnmounter.self))

    static let shared = AutoVolumeUnmounter()

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

      timerTask = Task { @MainActor in
        checkAndUnmount()

        for await _ in timer {
          checkAndUnmount()
        }
      }
    }

    deinit {
      timerTask?.cancel()
    }

    // Since timerTask strongly references self, call cancelTimer when AutoVolumeUnmounter is no longer needed.
    func cancelTimer() {
      timerTask?.cancel()
    }

    private func checkAndUnmount() {
      let resourceKeys: Set<URLResourceKey> = [
        .volumeUUIDStringKey
      ]

      let mountedVolumes =
        FileManager.default.mountedVolumeURLs(
          includingResourceValuesForKeys: Array(resourceKeys),
          options: []
        ) ?? []

      for volumeURL in mountedVolumes {
        guard let values = try? volumeURL.resourceValues(forKeys: resourceKeys),
          let uuid = values.volumeUUIDString
        else {
          continue
        }

        guard targetVolumeUUIDs.contains(uuid) else {
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

    private static let unmountCallback: DADiskUnmountCallback = { _, _, context in
      guard let context else {
        return
      }

      let unmountContext = Unmanaged<UnmountContext>.fromOpaque(context).takeRetainedValue()
      let owner = unmountContext.owner
      let uuid = unmountContext.uuid

      Task { @MainActor in
        owner?.unmountingVolumeUUIDs.remove(uuid)
      }
    }
  }
}
