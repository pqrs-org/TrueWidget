import SwiftUI

struct CompactView: View {
  @ObservedObject private var userSettings: UserSettings

  init(userSettings: UserSettings) {
    self.userSettings = userSettings
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      if CompactTimeView.isVisible(for: userSettings) {
        CompactTimeView(userSettings: userSettings)
      }

      if userSettings.compactShowCPUUsage {
        CompactCPUUsageView(userSettings: userSettings)
      }
    }
  }
}
