import Combine
import SettingsAccess
import SwiftUI

@main
struct TrueWidgetApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  @StateObject private var userSettings: UserSettings
  // Since passing a property of an ObservableObject to MenuBarExtra.isInserted causes a notification loop, the flag must be an independent variable.
  @AppStorage("showMenu") var showMenuBarExtra: Bool = true

  private var cancellables = Set<AnyCancellable>()
  private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

  init() {
    //
    // Initialize properties
    //

    let userSettings = UserSettings()

    _userSettings = StateObject(wrappedValue: userSettings)

    appDelegate.userSettings = userSettings

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
    // The main window is manually managed by MainWindowController.

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
  var mainWindowController: MainWindowController?
  var userSettings: UserSettings?

  func applicationDidFinishLaunching(_ notification: Notification) {
    guard let userSettings = userSettings else { return }

    mainWindowController = MainWindowController(userSettings: userSettings)
    mainWindowController?.showWindow(nil)
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool
  {
    NotificationCenter.default.post(
      name: openSettingsNotification,
      object: nil,
      userInfo: nil)
    return true
  }
}

class MainWindowController: NSWindowController {
  init(userSettings: UserSettings) {
    // Note:
    // On macOS 13, the only way to remove the title bar is to manually create an NSWindow like this.
    //
    // The following methods do not work properly:
    // - .windowStyle(.hiddenTitleBar) does not remove the window frame.
    // - NSApp.windows.first.styleMask = [.borderless] causes the app to crash.

    let window = NSWindow(
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

    window.backgroundColor = .clear
    window.isOpaque = false
    window.hasShadow = false
    window.ignoresMouseEvents = true
    window.level = .statusBar
    window.collectionBehavior.insert(.canJoinAllSpaces)
    window.collectionBehavior.insert(.ignoresCycle)
    window.collectionBehavior.insert(.stationary)
    window.contentView = NSHostingView(
      rootView: ContentView(window: window, userSettings: userSettings)
        .openSettingsAccess()
    )

    super.init(window: window)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
