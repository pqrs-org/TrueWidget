import AppKit
import SwiftUI

@NSApplicationMain
public class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
  private var window: NSWindow?

  private func setupWindow() {
    if let mainScreen = NSScreen.main {
      //
      // Determine screen
      //

      var screen = mainScreen
      if let widgetScreen = WidgetScreen(rawValue: UserSettings.shared.widgetScreen) {
        NSScreen.screens.forEach { s in
          //
          // +--------------------+--------------------+--------------------+
          // |                    |                    |                    |
          // |                    |                    |                    |
          // |                    |                    |                    |
          // |(-100,100)          |(0,100)             |(100,100)           |
          // +--------------------+--------------------+--------------------+
          // |                    |                    |                    |
          // |                    |        main        |                    |
          // |                    |                    |                    |
          // |(-100,0)            |(0,0)               |(100,0)             |
          // +--------------------+--------------------+--------------------+
          // |                    |                    |                    |
          // |                    |                    |                    |
          // |                    |                    |                    |
          // |(-100,-100)         |(0,-100)            |(100,-100)          |
          // +--------------------+--------------------+--------------------+
          //

          switch widgetScreen {
          case WidgetScreen.primary:
            if s.frame.origin == NSZeroPoint {
              screen = s
            }
          case WidgetScreen.bottomLeft:
            if s.frame.origin.x <= screen.frame.origin.x, s.frame.origin.y <= screen.frame.origin.y
            {
              screen = s
            }
          case WidgetScreen.bottomRight:
            if s.frame.origin.x >= screen.frame.origin.x, s.frame.origin.y <= screen.frame.origin.y
            {
              screen = s
            }
          case WidgetScreen.topLeft:
            if s.frame.origin.x <= screen.frame.origin.x, s.frame.origin.y >= screen.frame.origin.y
            {
              screen = s
            }
          case WidgetScreen.topRight:
            if s.frame.origin.x >= screen.frame.origin.x, s.frame.origin.y >= screen.frame.origin.y
            {
              screen = s
            }
          }
        }
      }

      //
      // Create window
      //

      if window == nil {
        window = NSWindow(
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

        window?.backgroundColor = .clear
        window?.isOpaque = false
        window?.hasShadow = false
        window?.ignoresMouseEvents = true
        window?.level = .statusBar
        window?.collectionBehavior.insert(.canJoinAllSpaces)
        window?.collectionBehavior.insert(.ignoresCycle)
        window?.collectionBehavior.insert(.stationary)
        window?.contentView = NSHostingView(rootView: MainView())
        window?.delegate = self
      }

      //
      // Determine origin
      //

      if let window = window {
        let screenFrame = screen.visibleFrame
        var origin = NSZeroPoint
        if let widgetPosition = WidgetPosition(rawValue: UserSettings.shared.widgetPosition) {
          switch widgetPosition {
          case WidgetPosition.bottomLeft:
            origin.x = screenFrame.origin.x + 10
            origin.y = screenFrame.origin.y + 10

          case WidgetPosition.topLeft:
            origin.x = screenFrame.origin.x + 10
            origin.y = screenFrame.origin.y + screenFrame.size.height - window.frame.height - 10

          case WidgetPosition.topRight:
            origin.x = screenFrame.origin.x + screenFrame.size.width - window.frame.width - 10
            origin.y = screenFrame.origin.y + screenFrame.size.height - window.frame.height - 10

          default:
            // WidgetPosition.bottomRight
            origin.x = screenFrame.origin.x + screenFrame.size.width - window.frame.width - 10
            origin.y = screenFrame.origin.y + 10
          }
        }

        //
        // Set window frame
        //

        window.setFrameOrigin(origin)
        window.orderFront(self)
      }
    }
  }

  public func applicationDidFinishLaunching(_: Notification) {
    NSApplication.shared.disableRelaunchOnLogin()

    if !OpenAtLogin.shared.developmentBinary {
      if !UserSettings.shared.initialOpenAtLoginRegistered {
        OpenAtLogin.shared.update(register: true)
        UserSettings.shared.initialOpenAtLoginRegistered = true
      }
    }

    NotificationCenter.default.addObserver(
      forName: NSApplication.didChangeScreenParametersNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      guard let self = self else { return }

      self.setupWindow()
    }

    NotificationCenter.default.addObserver(
      forName: UserSettings.widgetPositionSettingChanged,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      guard let self = self else { return }

      self.setupWindow()
    }

    NotificationCenter.default.addObserver(
      forName: UserSettings.showMenuSettingChanged,
      object: nil,
      queue: .main
    ) { _ in
      MenuController.shared.show()
    }

    setupWindow()

    Updater.shared.checkForUpdatesInBackground()

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
    Task { @MainActor in
      self.setupWindow()
    }
  }
}
