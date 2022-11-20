import AppKit
import SwiftUI

@NSApplicationMain
public class AppDelegate: NSObject, NSApplicationDelegate {
  private var windows: [NSWindow] = []

  private func setupWindows() {
    let screens = NSScreen.screens

    let operatingSystemVersion = "macOS \(operatingSystemVersionString())"

    while windows.count < screens.count {
      let w = NSWindow(
        contentRect: .zero,
        styleMask: [
          .borderless,
          .fullSizeContentView,
        ],
        backing: .buffered,
        defer: false
      )

      // Note: Do not set alpha value for window.
      // Window with alpha value causes glitch at switching a space (Mission Control).

      w.backgroundColor = NSColor.clear
      w.isOpaque = false
      w.hasShadow = false
      w.ignoresMouseEvents = true
      w.level = .statusBar
      w.collectionBehavior.insert(.canJoinAllSpaces)
      w.collectionBehavior.insert(.ignoresCycle)
      w.collectionBehavior.insert(.stationary)
      w.contentView = NSHostingView(
        rootView: MainView(operatingSystemVersion: operatingSystemVersion))

      windows.append(w)
    }

    //
    // Update frame
    //

    for (i, w) in windows.enumerated() {
      if i < screens.count {
        let screenFrame = screens[i].frame
        let width = 250.0
        let height = 100.0

        w.setFrame(
          NSMakeRect(
            screenFrame.origin.x + 10,
            screenFrame.origin.y + 10,
            width,
            height
          ),
          display: true
        )

        w.orderFront(self)
      }
    }
  }

  public func applicationDidFinishLaunching(_: Notification) {
    NSApplication.shared.disableRelaunchOnLogin()

    NotificationCenter.default.addObserver(
      forName: NSApplication.didChangeScreenParametersNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      guard let self = self else { return }

      self.setupWindows()
    }

    setupWindows()
  }

  private func operatingSystemVersionString() -> String {
    return ProcessInfo.processInfo.operatingSystemVersionString
  }
}
