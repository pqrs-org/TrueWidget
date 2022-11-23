import Combine
import Foundation

final class UserSettings: ObservableObject {
  static let shared = UserSettings()
  static let showMenuSettingChanged = Notification.Name("ShowMenuSettingChanged")
  static let uiLayoutChanged = Notification.Name("UILayoutChanged")

  @Published var openAtLogin = OpenAtLogin.enabled {
    didSet {
      OpenAtLogin.enabled = openAtLogin
    }
  }

  //
  // Menu settings
  //

  @UserDefault("showMenu", defaultValue: true)
  var showMenu: Bool {
    willSet {
      objectWillChange.send()
    }
    didSet {
      NotificationCenter.default.post(
        name: UserSettings.showMenuSettingChanged,
        object: nil
      )
    }
  }

  //
  // Layout
  //

  @UserDefault("widgetWidth", defaultValue: 250.0)
  var widgetWidth: Double {
    willSet {
      objectWillChange.send()
    }
    didSet {
      NotificationCenter.default.post(
        name: UserSettings.uiLayoutChanged,
        object: nil
      )
    }
  }

  //
  // Operating system
  //

  @UserDefault("showOperatingSystem", defaultValue: true)
  var showOperatingSystem: Bool {
    willSet {
      objectWillChange.send()
    }
    didSet {
      NotificationCenter.default.post(
        name: UserSettings.uiLayoutChanged,
        object: nil
      )
    }
  }

  @UserDefault("operatingSystemFontSize", defaultValue: 14.0)
  var operatingSystemFontSize: Double {
    willSet {
      objectWillChange.send()
    }
    didSet {
      NotificationCenter.default.post(
        name: UserSettings.uiLayoutChanged,
        object: nil
      )
    }
  }

  //
  // CPU usage
  //

  @UserDefault("showCPUUsage", defaultValue: true)
  var showCPUUsage: Bool {
    willSet {
      objectWillChange.send()
    }
    didSet {
      NotificationCenter.default.post(
        name: UserSettings.uiLayoutChanged,
        object: nil
      )
    }
  }

  @UserDefault("cpuUsageFontSize", defaultValue: 36.0)
  var cpuUsageFontSize: Double {
    willSet {
      objectWillChange.send()
    }
    didSet {
      NotificationCenter.default.post(
        name: UserSettings.uiLayoutChanged,
        object: nil
      )
    }
  }

  //
  // Local time
  //

  @UserDefault("showLocalTime", defaultValue: true)
  var showLocalTime: Bool {
    willSet {
      objectWillChange.send()
    }
    didSet {
      NotificationCenter.default.post(
        name: UserSettings.uiLayoutChanged,
        object: nil
      )
    }
  }

  @UserDefault("localTimeFontSize", defaultValue: 36.0)
  var localTimeFontSize: Double {
    willSet {
      objectWillChange.send()
    }
    didSet {
      NotificationCenter.default.post(
        name: UserSettings.uiLayoutChanged,
        object: nil
      )
    }
  }
}
