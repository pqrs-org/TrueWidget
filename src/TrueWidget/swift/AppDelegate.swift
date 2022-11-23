import AppKit
import SwiftUI

@NSApplicationMain
public class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
  private var windows: [NSWindow] = []

  private func setupWindows() {
    let screens = NSScreen.screens

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
      w.contentView = NSHostingView(rootView: MainView())
      w.delegate = self

      windows.append(w)
    }

    updateWindowsFrame()
  }

  public func updateWindowsFrame() {
    let screens = NSScreen.screens

    for (i, w) in windows.enumerated() {
      if i < screens.count {
        let screenFrame = screens[i].frame

        w.setFrameOrigin(
          NSMakePoint(
            screenFrame.origin.x + 10,
            screenFrame.origin.y + 10
          )
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

    NotificationCenter.default.addObserver(
      forName: UserSettings.uiLayoutChanged,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      guard let self = self else { return }

      self.setupWindows()
    }

    NotificationCenter.default.addObserver(
      forName: UserSettings.showMenuSettingChanged,
      object: nil,
      queue: .main
    ) { _ in
      MenuController.shared.show()
    }

    setupWindows()

    MenuController.shared.show()
  }

  public func applicationShouldHandleReopen(
    _: NSApplication,
    hasVisibleWindows _: Bool
  ) -> Bool {
    SettingsWindowManager.shared.show()
    return true
  }

  public func windowDidResize(_ notification: Notification) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      self.updateWindowsFrame()
    }
  }
}
