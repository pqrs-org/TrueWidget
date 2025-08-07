import SettingsAccess
import SwiftUI

struct ContentView: View {
  @Environment(\.openSettingsLegacy) var openSettingsLegacy
  private var window: NSWindow
  @ObservedObject private var userSettings: UserSettings
  @StateObject private var displayMonitor = DisplayMonitor()

  @State private var hidden = false
  private let windowPositionManager: WindowPositionManager

  init(window: NSWindow, userSettings: UserSettings) {
    self.window = window
    self.userSettings = userSettings
    windowPositionManager = WindowPositionManager(window: window, userSettings: userSettings)
  }

  var body: some View {
    VStack {
      if isCompactView() {
        CompactView(userSettings: userSettings)
      } else {
        VStack(alignment: .leading, spacing: 10.0) {
          if MainOperatingSystemView.isVisible(for: userSettings) {
            MainOperatingSystemView(userSettings: userSettings)
          }

          if MainXcodeView.isVisible(for: userSettings) {
            MainXcodeView(userSettings: userSettings)
          }

          if MainBundleView.isVisible(for: userSettings) {
            MainBundleView(userSettings: userSettings)
          }

          if MainCPUUsageView.isVisible(for: userSettings) {
            MainCPUUsageView(userSettings: userSettings)
          }

          if MainTimeView.isVisible(for: userSettings) {
            MainTimeView(userSettings: userSettings)
          }
        }
      }
    }
    .padding()
    .if(!isCompactView()) {
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

  private func isCompactView() -> Bool {
    switch userSettings.widgetAppearance {
    case WidgetAppearance.compact.rawValue:
      return true
    case WidgetAppearance.autoCompact.rawValue:
      if displayMonitor.displayCount <= userSettings.autoCompactDisplayCount {
        return true
      }
      return false
    default:
      return false
    }
  }
}
