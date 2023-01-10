import SwiftUI

struct SettingsCPUUsageView: View {
  @ObservedObject private var userSettings = UserSettings.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("CPU usage")) {
        VStack(alignment: .leading) {
          HStack {
            Toggle(isOn: $userSettings.showCPUUsage) {
              Text("Show CPU usage")
            }
            .switchToggleStyle()

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
        }
        .padding()
      }

      if userSettings.showCPUUsage {
        GroupBox(label: Text("Advanced")) {
          VStack(alignment: .leading) {
            HStack {
              Picker(selection: $userSettings.cpuUsageType, label: Text("Value: ")) {
                Text("Moving Average (Default)").tag(CPUUsageType.movingAverage.rawValue)
                Text("Latest").tag(CPUUsageType.latest.rawValue)
              }

              Spacer()
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

              Spacer()
            }

            HStack {
              Toggle(isOn: $userSettings.showProcesses) {
                Text("Show processes")
              }
              .switchToggleStyle()

              Spacer()
            }
            .padding(.top, 20.0)

            HStack {
              Text("Processes font size: ")

              DoubleTextField(
                value: $userSettings.processesFontSize,
                range: 0...1000,
                step: 2,
                width: 40)

              Text("pt")

              Text("(Default: 12 pt)")

              Spacer()
            }
          }
          .padding()
        }
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
