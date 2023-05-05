import Combine
import Foundation

enum WidgetPosition: String {
  case bottomLeft
  case bottomRight
  case topLeft
  case topRight
}

enum WidgetScreen: String {
  case primary
  case bottomLeft
  case bottomRight
  case topLeft
  case topRight
}

enum CPUUsageType: String {
  case movingAverage
  case latest
}

final class UserSettings: ObservableObject {
  static let shared = UserSettings()
  static let showMenuSettingChanged = Notification.Name("ShowMenuSettingChanged")
  static let widgetPositionSettingChanged = Notification.Name("WidgetPositionSettingChanged")

  //
  // Open at login
  //

  @Published var openAtLogin = OpenAtLogin.shared.registered {
    didSet {
      OpenAtLogin.shared.update(register: openAtLogin)
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

  @UserDefault("widgetPosition", defaultValue: WidgetPosition.bottomRight.rawValue)
  var widgetPosition: String {
    willSet {
      objectWillChange.send()
    }
    didSet {
      NotificationCenter.default.post(
        name: UserSettings.widgetPositionSettingChanged,
        object: nil
      )
    }
  }

  @UserDefault("widgetWidth", defaultValue: 250.0)
  var widgetWidth: Double {
    willSet {
      objectWillChange.send()
    }
  }

  @UserDefault("widgetOpacity", defaultValue: 0.8)
  var widgetOpacity: Double {
    willSet {
      objectWillChange.send()
    }
  }

  @UserDefault("widgetScreen", defaultValue: WidgetScreen.primary.rawValue)
  var widgetScreen: String {
    willSet {
      objectWillChange.send()
    }
    didSet {
      NotificationCenter.default.post(
        name: UserSettings.widgetPositionSettingChanged,
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
  }

  @UserDefault("operatingSystemFontSize", defaultValue: 14.0)
  var operatingSystemFontSize: Double {
    willSet {
      objectWillChange.send()
    }
  }

  @UserDefault("showHostName", defaultValue: true)
  var showHostName: Bool {
    willSet {
      objectWillChange.send()
    }
  }

  @UserDefault("showRootVolumeName", defaultValue: false)
  var showRootVolumeName: Bool {
    willSet {
      objectWillChange.send()
    }
  }

  @UserDefault("showUserName", defaultValue: false)
  var showUserName: Bool {
    willSet {
      objectWillChange.send()
    }
  }

  //
  // Xcode
  //

  @UserDefault("showXcode", defaultValue: false)
  var showXcode: Bool {
    willSet {
      objectWillChange.send()
    }
  }

  @UserDefault("xcodeFontSize", defaultValue: 12.0)
  var xcodeFontSize: Double {
    willSet {
      objectWillChange.send()
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
  }

  @UserDefault("cpuUsageFontSize", defaultValue: 36.0)
  var cpuUsageFontSize: Double {
    willSet {
      objectWillChange.send()
    }
  }

  @UserDefault("cpuUsageType", defaultValue: CPUUsageType.movingAverage.rawValue)
  var cpuUsageType: String {
    willSet {
      objectWillChange.send()
    }
  }

  @UserDefault("cpuUsageMovingAverageRange", defaultValue: 30)
  var cpuUsageMovingAverageRange: Int {
    willSet {
      objectWillChange.send()
    }
  }

  @UserDefault("showProcesses", defaultValue: true)
  var showProcesses: Bool {
    willSet {
      objectWillChange.send()
    }
  }

  @UserDefault("processesFontSize", defaultValue: 12.0)
  var processesFontSize: Double {
    willSet {
      objectWillChange.send()
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
  }

  @UserDefault("localTimeFontSize", defaultValue: 36.0)
  var localTimeFontSize: Double {
    willSet {
      objectWillChange.send()
    }
  }

  @UserDefault("showLocalDate", defaultValue: true)
  var showLocalDate: Bool {
    willSet {
      objectWillChange.send()
    }
  }

  @UserDefault("localDateFontSize", defaultValue: 12.0)
  var localDateFontSize: Double {
    willSet {
      objectWillChange.send()
    }
  }

  //
  // Another time zone time
  //

  struct TimeZoneTimeSetting: Identifiable, Codable {
    var id = UUID().uuidString
    var show = false
    var abbreviation: String = "UTC"
  }

  @UserDefaultJson("timeZoneTimeSettings", defaultValue: [])
  var timeZoneTimeSettings: [TimeZoneTimeSetting] {
    willSet {
      objectWillChange.send()
    }
  }

  func initializeTimeZoneTimeSettings() {
    let maxCount = 5
    while timeZoneTimeSettings.count < maxCount {
      timeZoneTimeSettings.append(TimeZoneTimeSetting())
    }
  }

  @UserDefault("timeZoneTimeFontSize", defaultValue: 12.0)
  var timeZoneTimeFontSize: Double {
    willSet {
      objectWillChange.send()
    }
  }
}
