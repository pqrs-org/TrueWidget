import SwiftUI

struct CompactView: View {
  @ObservedObject private var userSettings: UserSettings

  init(userSettings: UserSettings) {
    self.userSettings = userSettings
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      CompactTimeView(userSettings: userSettings)
      CompactCPUUsageView(userSettings: userSettings)
    }
  }
}
