import SwiftUI

class SettingsWindowManager: NSObject {
  static let shared = SettingsWindowManager()

  private var window: NSWindow?
  private var closed = false

  func show() {
    if window != nil, !closed {
      window!.makeKeyAndOrderFront(self)
      NSApp.activate(ignoringOtherApps: true)
      return
    }

    closed = false

    window = NSWindow(
      contentRect: .zero,
      styleMask: [
        .titled,
        .closable,
        .miniaturizable,
        .fullSizeContentView,
      ],
      backing: .buffered,
      defer: false
    )

    window!.isReleasedWhenClosed = false
    window!.title = "TrueWidget Settings"
    window!.contentView = NSHostingView(rootView: SettingsView())
    window!.delegate = self
    window!.center()

    window!.makeKeyAndOrderFront(self)
    NSApp.activate(ignoringOtherApps: true)
  }
}

extension SettingsWindowManager: NSWindowDelegate {
  func windowWillClose(_: Notification) {
    closed = true
  }
}
