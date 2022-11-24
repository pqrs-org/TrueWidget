import SwiftUI

struct SettingsCPUUsageView: View {
  @ObservedObject private var userSettings = UserSettings.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("CPU usage")) {
        VStack(alignment: .leading, spacing: 10.0) {
          HStack {
            Toggle(isOn: $userSettings.showCPUUsage) {
              Text("Show CPU usage")
            }

            Spacer()
          }

          HStack {
            Text("Font size: ")

            DoubleTextField(
              value: $userSettings.cpuUsageFontSize,
              range: 0...1000,
              step: 2,
              width: 40)

            Text("pt")

            Text("(Default: 36 pt)")

            Spacer()
          }

          HStack {
            Picker(selection: $userSettings.cpuUsageType, label: Text("Value: ")) {
              Text("Moving Average (Default)").tag(CPUUsageType.movingAverage.rawValue)
              Text("Latest").tag(CPUUsageType.latest.rawValue)
            }

            Spacer()
          }
        }
        .padding()
      }

      Spacer()
    }
  }
}

struct SettingsCPUUsageView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsCPUUsageView()
      .previewLayout(.sizeThatFits)
  }
}
