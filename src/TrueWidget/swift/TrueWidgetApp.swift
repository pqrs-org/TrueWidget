import SettingsAccess
import SwiftUI

@main
struct TrueWidgetApp: App {
  @StateObject private var userSettings: UserSettings
  @StateObject private var windowBehaviorManager: WindowBehaviorManager
  // Since passing a property of an ObservableObject to MenuBarExtra.isInserted causes a notification loop, the flag must be an independent variable.
  @AppStorage("showMenu") var showMenuBarExtra: Bool = true

  private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""

  init() {
    //
    // Initialize properties
    //

    let userSettings = UserSettings()

    _userSettings = StateObject(wrappedValue: userSettings)
    _windowBehaviorManager = StateObject(
      wrappedValue: WindowBehaviorManager(userSettings: userSettings))

    //
    // Register OpenAtLogin
    //

    if !OpenAtLogin.shared.developmentBinary {
      if !UserSettings.shared.initialOpenAtLoginRegistered {
        OpenAtLogin.shared.update(register: true)
        UserSettings.shared.initialOpenAtLoginRegistered = true
      }
    }

    //
    // Additional setups
    //

    NSApplication.shared.disableRelaunchOnLogin()

    //
    // NotificationCenter.default.addObserver(
    //   forName: NSApplication.didChangeScreenParametersNotification,
    //   object: nil,
    //   queue: .main
    // ) { [weak self] _ in
    //   guard let self = self else { return }
    //
    //   self.setupWindow()
    // }
    //
    // NotificationCenter.default.addObserver(
    //   forName: UserSettings.widgetPositionSettingChanged,
    //   object: nil,
    //   queue: .main
    // ) { [weak self] _ in
    //   guard let self = self else { return }
    //
    //   self.setupWindow()
    // }
    //
    // setupWindow()
    //
    // Updater.shared.checkForUpdatesInBackground()
  }

  var body: some Scene {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openSettingsLegacy) var openSettingsLegacy

    WindowGroup {
      ContentView()
        .background(WindowConfigurator())
        .onAppear {
          Task {
            windowBehaviorManager.updateWindowPosition()
          }
        }
        .openSettingsAccess()
        .onReceive(NotificationCenter.default.publisher(for: windowResizedNotification)) { _ in
          windowBehaviorManager.updateWindowPosition()
        }
        .onReceive(NotificationCenter.default.publisher(for: openSettingsNotification)) { _ in
          Task { @MainActor in
            try? openSettingsLegacy()
          }
        }
    }

    MenuBarExtra(
      isInserted: $showMenuBarExtra,
      content: {
        Text("TrueWidget \(version)")

        Divider()

        SettingsLink {
          Text("Settings...")
        } preAction: {
          NSApp.activate(ignoringOtherApps: true)
        } postAction: {
        }

        Divider()

        Button("Quit TrueWidget") {
          NSApp.terminate(nil)
        }
      },
      label: {
        Label(
          title: { Text("TrueWidget") },
          icon: {
            // To prevent the menu icon from appearing blurry, it is necessary to explicitly set the displayScale.
            Image("menu")
              .environment(\.displayScale, 2.0)
          }
        )
      }
    )

    Settings {
      SettingsView(showMenuBarExtra: $showMenuBarExtra)
        .environmentObject(userSettings)
    }
  }
}

struct WindowConfigurator: NSViewRepresentable {
  func makeNSView(context: Context) -> NSView {
    let view = NSView()

    Task { @MainActor in
      if let window = view.window {
        window.styleMask = [.borderless]
        // Note: Do not set alpha value for window.
        // Window with alpha value causes glitch at switching a space (Mission Control).
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.level = .statusBar
        window.collectionBehavior.insert(.canJoinAllSpaces)
        window.collectionBehavior.insert(.ignoresCycle)
        window.collectionBehavior.insert(.stationary)
      }
    }
    return view
  }

  func updateNSView(_ nsView: NSView, context: Context) {}
}

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool
  {
    NotificationCenter.default.post(
      name: openSettingsNotification,
      object: nil,
      userInfo: nil)
    return true
  }

  func windowDidResize(_ notification: Notification) {
    NotificationCenter.default.post(
      name: windowResizedNotification,
      object: nil,
      userInfo: nil)
  }
}
