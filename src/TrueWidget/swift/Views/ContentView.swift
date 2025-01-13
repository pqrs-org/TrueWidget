import SettingsAccess
import SwiftUI

struct ContentView: View {
  @Environment(\.openSettingsLegacy) var openSettingsLegacy
  private var window: NSWindow
  @ObservedObject private var userSettings: UserSettings

  @State private var hidden = false
  private let windowPositionManager: WindowPositionManager

  init(window: NSWindow, userSettings: UserSettings) {
    self.window = window
    self.userSettings = userSettings
    windowPositionManager = WindowPositionManager(window: window, userSettings: userSettings)
  }

  var body: some View {
    VStack {
      if userSettings.widgetAppearance == WidgetAppearance.compact.rawValue {
        CompactView(userSettings: userSettings)
      } else {
        VStack(alignment: .leading, spacing: 10.0) {
          if userSettings.showOperatingSystem {
            MainOperatingSystemView(userSettings: userSettings)
          }

          if userSettings.showXcode {
            MainXcodeView(userSettings: userSettings)
          }

          if !userSettings.bundleSettings.filter({ $0.show }).isEmpty {
            MainBundleView(userSettings: userSettings)
          }

          if userSettings.showCPUUsage {
            MainCPUUsageView(userSettings: userSettings)
          }

          if userSettings.showLocalTime
            || userSettings.showLocalDate
            || !userSettings.timeZoneTimeSettings.filter({ $0.show }).isEmpty
          {
            MainTimeView(userSettings: userSettings)
          }
        }
      }
    }
    .padding()
    .if(userSettings.widgetAppearance != WidgetAppearance.compact.rawValue) {
      $0.frame(width: userSettings.widgetWidth)
    }
    .fixedSize()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(.black)
    )
    .foregroundColor(.white)
    .opacity(
      userSettings.widgetAppearance == WidgetAppearance.hidden.rawValue
        ? 0.0
        : (hidden ? 0.0 : userSettings.widgetOpacity)
    )
    .whenHovered { hover in
      if hover {
        withAnimation(.easeInOut(duration: userSettings.widgetFadeOutDuration / 1000.0)) {
          hidden = true
        }
      } else {
        hidden = false
      }
    }
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(.black, lineWidth: 4)
    )
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .onAppear {
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
  }
}
