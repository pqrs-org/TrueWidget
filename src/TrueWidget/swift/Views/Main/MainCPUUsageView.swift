import SwiftUI

struct MainCPUUsageView: View {
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

    VStack(alignment: .trailing, spacing: 0.0) {
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
      .if(!userSettings.showProcesses) {
        $0.overlay(
          Rectangle()
            .frame(height: 1.0),
          alignment: .bottom
        )
      }
      .font(.custom("Menlo", size: userSettings.cpuUsageFontSize))

      if userSettings.showProcesses {
        VStack(alignment: .trailing, spacing: 0) {
          ForEach(Array(cpuUsage.processes.enumerated()), id: \.0) { _, process in
            Text(
              "\(process["name"] ?? "---") \((process["cpu"] ?? "---").leftPadding(toLength: 6, withPad: " "))%"
            )
          }
        }
        .padding(.vertical, 4.0)
        .padding(.horizontal, 10.0)
        .font(.custom("Menlo", size: userSettings.processesFontSize))
        .border(.gray)
      }
    }
    .frame(maxWidth: .infinity, alignment: .trailing)
    .onDisappear {
      cpuUsage.cancelTimer()
    }
  }
}
