import SwiftUI

struct CompactCPUUsageView: View {
  @ObservedObject private var userSettings: UserSettings
  @StateObject private var cpuUsage: WidgetSource.CPUUsage

  init(userSettings: UserSettings) {
    self.userSettings = userSettings
    _cpuUsage = StateObject(wrappedValue: WidgetSource.CPUUsage(userSettings: userSettings))
  }

  var body: some View {
    //
    // CPU usage
    //

    VStack(alignment: .leading, spacing: 0.0) {
      HStack(alignment: .center, spacing: 0) {
        Spacer()

        HStack(alignment: .firstTextBaseline, spacing: 0) {
          Text("CPU")
            .font(.system(size: userSettings.cpuUsageFontSize / 2))

          if userSettings.cpuUsageType == CPUUsageType.latest.rawValue {
            Text(String(format: "% 3d", cpuUsage.usageInteger))

            Text(String(format: ".%02d%%", cpuUsage.usageDecimal))
              .font(.custom("Menlo", size: userSettings.cpuUsageFontSize / 2))
          } else {
            // Moving average
            Text(String(format: "% 3d", cpuUsage.usageAverageInteger))

            Text(String(format: ".%02d%%", cpuUsage.usageAverageDecimal))
              .font(.custom("Menlo", size: userSettings.cpuUsageFontSize / 2))
          }
        }
      }
      .font(.custom("Menlo", size: userSettings.cpuUsageFontSize))
    }
    .onDisappear {
      cpuUsage.cancelTimer()
    }
  }
}
