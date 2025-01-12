import SwiftUI

struct CompactView: View {
  @ObservedObject private var userSettings: UserSettings

  init(userSettings: UserSettings) {
    self.userSettings = userSettings
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      if userSettings.compactShowLocalTime {
        CompactTimeView(userSettings: userSettings)
      }
      if userSettings.compactShowCPUUsage {
        CompactCPUUsageView(userSettings: userSettings)
      }
    }
  }
}
