import Combine
import Foundation
import SwiftUI

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
  case leftTop
  case leftBottom
  case rightTop
  case rightBottom
}

enum WidgetAppearance: String {
  case normal
  case compact
  case hidden
}

enum CPUUsageType: String {
  case movingAverage
  case latest
}

struct TimeZoneTimeSetting: Identifiable, Codable {
  var id = UUID().uuidString
  var show = false
  var abbreviation: String = "UTC"
}

struct BundleSetting: Identifiable, Codable {
  var id = UUID().uuidString
  var show = false
  var url: URL?
}

final class UserSettings: ObservableObject {
  init() {
    initializeTimeZoneTimeSettings()
    initializeBundleSettings()
  }

  @AppStorage("initialOpenAtLoginRegistered") var initialOpenAtLoginRegistered: Bool = false

  //
  // Layout
  //

  @AppStorage("widgetPosition") var widgetPosition: String = WidgetPosition.bottomRight.rawValue
  @AppStorage("widgetWidth") var widgetWidth: Double = 250.0
  @AppStorage("widgetOpacity") var widgetOpacity: Double = 0.8
  @AppStorage("widgetScreen") var widgetScreen: String = WidgetScreen.primary.rawValue
  @AppStorage("widgetFadeOutDuration") var widgetFadeOutDuration: Double = 500.0
  @AppStorage("widgetAppearance") var widgetAppearance: String = WidgetAppearance.normal.rawValue

  //
  // Operating system
  //

  @AppStorage("showOperatingSystem") var showOperatingSystem: Bool = true
  @AppStorage("operatingSystemFontSize") var operatingSystemFontSize: Double = 14.0
  @AppStorage("showHostName") var showHostName: Bool = true
  @AppStorage("showRootVolumeName") var showRootVolumeName: Bool = false
  @AppStorage("showUserName") var showUserName: Bool = false

  //
  // Xcode
  //

  @AppStorage("showXcode") var showXcode: Bool = false
  @AppStorage("xcodeFontSize") var xcodeFontSize: Double = 12.0

  //
  // CPU usage
  //

  @AppStorage("showCPUUsage") var showCPUUsage: Bool = true
  @AppStorage("cpuUsageFontSize") var cpuUsageFontSize: Double = 36.0
  @AppStorage("cpuUsageType") var cpuUsageType: String = CPUUsageType.movingAverage.rawValue
  @AppStorage("cpuUsageMovingAverageRange") var cpuUsageMovingAverageRange: Int = 30
  @AppStorage("showProcesses") var showProcesses: Bool = true
  @AppStorage("processesFontSize") var processesFontSize: Double = 12.0

  //
  // Local time
  //

  @AppStorage("showLocalTime") var showLocalTime: Bool = true
  @AppStorage("localTimeFontSize") var localTimeFontSize: Double = 36.0
  @AppStorage("showLocalDate") var showLocalDate: Bool = true
  @AppStorage("localDateFontSize") var localDateFontSize: Double = 12.0

  //
  // Another time zone time
  //

  @CodableAppStorage("timeZoneTimeSettings") var timeZoneTimeSettings: [TimeZoneTimeSetting] = [] {
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

  @AppStorage("timeZoneDateFontSize") var timeZoneDateFontSize: Double = 10.0
  @AppStorage("timeZoneTimeFontSize") var timeZoneTimeFontSize: Double = 12.0

  //
  // Bundle
  //

  @CodableAppStorage("bundleSettings") var bundleSettings: [BundleSetting] = [] {
    willSet {
      objectWillChange.send()
    }
  }

  func initializeBundleSettings() {
    let maxCount = 10
    while bundleSettings.count < maxCount {
      if bundleSettings.isEmpty {
        bundleSettings.append(
          BundleSetting(
            url: URL(filePath: "/Applications/TrueWidget.app")
          ))
      } else {
        bundleSettings.append(BundleSetting())
      }
    }
  }

  @AppStorage("bundleFontSize") var bundleFontSize: Double = 12.0

}
