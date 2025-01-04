import Combine
import SettingsAccess
import SwiftUI

@main
struct TrueWidgetApp: App {
  @StateObject private var userSettings: UserSettings
  @StateObject private var windowPositionManager: WindowPositionManager
  // Since passing a property of an ObservableObject to MenuBarExtra.isInserted causes a notification loop, the flag must be an independent variable.
  @AppStorage("showMenu") var showMenuBarExtra: Bool = true

  private var cancellables = Set<AnyCancellable>()
  private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""

  init() {
    //
    // Initialize properties
    //

    let userSettings = UserSettings()

    _userSettings = StateObject(wrappedValue: userSettings)
    _windowPositionManager = StateObject(
      wrappedValue: WindowPositionManager(userSettings: userSettings))

    //
    // Register OpenAtLogin
    //

    if !OpenAtLogin.shared.developmentBinary {
      if !userSettings.initialOpenAtLoginRegistered {
        OpenAtLogin.shared.update(register: true)
        userSettings.initialOpenAtLoginRegistered = true
      }
    }

    //
    // Additional setups
    //

    NSApplication.shared.disableRelaunchOnLogin()

    NotificationCenter.default.addObserver(
      forName: NSApplication.didChangeScreenParametersNotification,
      object: nil,
      queue: .main
    ) { _ in
      postWindowPositionUpdateNeededNotification()
    }

    userSettings.objectWillChange.sink { _ in
      postWindowPositionUpdateNeededNotification()
    }.store(in: &cancellables)

    Updater.shared.checkForUpdatesInBackground()
  }

  var body: some Scene {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openSettingsLegacy) var openSettingsLegacy

    Window("TrueWidget", id: "true-widget") {
      ContentView()
        .openSettingsAccess()
        .environmentObject(userSettings)
        .onAppear {
          if let window = NSApp.windows.first {
            // Note: Do not set alpha value for window.
            // Window with alpha value causes glitch at switching a space (Mission Control).

            window.styleMask = [.borderless]
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = false
            window.ignoresMouseEvents = true
            window.level = .statusBar
            window.collectionBehavior.insert(.canJoinAllSpaces)
            window.collectionBehavior.insert(.ignoresCycle)
            window.collectionBehavior.insert(.stationary)
          }

          windowPositionManager.updateWindowPosition()
        }
        .onReceive(
          NotificationCenter.default.publisher(for: windowPositionUpdateNeededNotification)
        ) { _ in
          Task { @MainActor in
            windowPositionManager.updateWindowPosition()
          }
        }
        .onReceive(NotificationCenter.default.publisher(for: openSettingsNotification)) { _ in
          Task { @MainActor in
            try? openSettingsLegacy()
          }
        }
        .overlay(
          GeometryReader { geometry in
            Color.clear
              .onChange(of: geometry.size) { _ in
                postWindowPositionUpdateNeededNotification()
              }
          }
        )
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

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool
  {
    NotificationCenter.default.post(
      name: openSettingsNotification,
      object: nil,
      userInfo: nil)
    return true
  }
}
