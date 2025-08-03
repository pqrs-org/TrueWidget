import CoreGraphics
import SwiftUI

@MainActor
public class DisplayMonitor: ObservableObject {
  @Published var displayCount = 0

  init() {
    updateDisplayCount()
    CGDisplayRegisterReconfigurationCallback(callback, Unmanaged.passUnretained(self).toOpaque())
  }

  deinit {
    CGDisplayRemoveReconfigurationCallback(callback, Unmanaged.passUnretained(self).toOpaque())
  }

  private func updateDisplayCount() {
    Task { @MainActor in
      var displayCount: UInt32 = 0
      var onlineDisplays = [CGDirectDisplayID](repeating: 0, count: 16)
      CGGetOnlineDisplayList(UInt32(onlineDisplays.count), &onlineDisplays, &displayCount)

      self.displayCount = Int(displayCount)
    }
  }

  private let callback: CGDisplayReconfigurationCallBack = { _, flags, userInfo in
    if flags.isDisjoint(with: [.addFlag, .removeFlag]) {
      guard let opaque = userInfo else {
        return
      }

      let monitor =
        Unmanaged<DisplayMonitor>.fromOpaque(opaque).takeUnretainedValue() as DisplayMonitor
      monitor.updateDisplayCount()
    }
  }
}
