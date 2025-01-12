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

    HStack(alignment: .firstTextBaseline, spacing: 0) {
      Text("CPU")

      if userSettings.cpuUsageType == CPUUsageType.latest.rawValue {
        Text(
          String(
            format: "% 3d.%02d%%",
            cpuUsage.usageInteger,
            cpuUsage.usageDecimal))
      } else {
        // Moving average
        Text(
          String(
            format: "% 3d.%02d%%",
            cpuUsage.usageAverageInteger,
            cpuUsage.usageAverageDecimal))
      }
    }
    .font(.custom("Menlo", size: userSettings.compactCPUUsageFontSize))
    .frame(maxWidth: .infinity, alignment: .trailing)
    .onDisappear {
      cpuUsage.cancelTimer()
    }
  }
}
