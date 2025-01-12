import SwiftUI

struct SettingsCPUUsageView: View {
  @EnvironmentObject private var userSettings: UserSettings

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("CPU usage")) {
        VStack(alignment: .leading) {
          Toggle(isOn: $userSettings.showCPUUsage) {
            Text("Show CPU usage")
          }
          .switchToggleStyle()

          HStack {
            Text("Font size: ")

            DoubleTextField(
              value: $userSettings.cpuUsageFontSize,
              range: 0...1000,
              step: 2,
              maximumFractionDigits: 1,
              width: 40)

            Text("pt")

            Text("(Default: 36 pt)")
          }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      if userSettings.showCPUUsage {
        GroupBox(label: Text("Advanced")) {
          VStack(alignment: .leading) {
            Picker(selection: $userSettings.cpuUsageType, label: Text("Value: ")) {
              Text("Moving Average (Default)").tag(CPUUsageType.movingAverage.rawValue)
              Text("Latest").tag(CPUUsageType.latest.rawValue)
            }

            HStack {
              Text("Moving Average periods: ")

              IntTextField(
                value: $userSettings.cpuUsageMovingAverageRange,
                range: 0...1000,
                step: 5,
                width: 40)

              Text("seconds")

              Text("(Default: 30 seconds)")
            }

            Toggle(isOn: $userSettings.showProcesses) {
              Text("Show processes")
            }
            .switchToggleStyle()
            .padding(.top, 20.0)

            HStack {
              Text("Processes font size: ")

              DoubleTextField(
                value: $userSettings.processesFontSize,
                range: 0...1000,
                step: 2,
                maximumFractionDigits: 1,
                width: 40)

              Text("pt")

              Text("(Default: 12 pt)")
            }
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
  }
}
