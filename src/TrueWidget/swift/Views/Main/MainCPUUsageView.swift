import SwiftUI

struct MainCPUUsageView: View {
  @ObservedObject private var userSettings = UserSettings.shared
  @ObservedObject private var cpuUsage = WidgetSource.CPUUsage.shared

  var body: some View {
    //
    // CPU usage
    //

    VStack(alignment: .leading, spacing: 4.0) {
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
        .overlay(
          Rectangle()
            .frame(height: 1.0),
          alignment: .bottom
        )
      }
      .font(.custom("Menlo", size: userSettings.cpuUsageFontSize))

      VStack(alignment: .leading, spacing: 0) {
        ForEach($cpuUsage.processes, id: \.self) { $process in
          HStack(alignment: .center, spacing: 0) {
            Spacer()
            Text("\(process["name"] ?? "---")")
            Text("\((process["cpu"] ?? "---").leftPadding(toLength: 6, withPad: " "))%")
          }
        }
      }
      .font(.custom("Menlo", size: 12))
    }
  }
}

struct MainCPUUsageView_Previews: PreviewProvider {
  static var previews: some View {
    MainCPUUsageView()
      .previewLayout(.sizeThatFits)
  }
}
