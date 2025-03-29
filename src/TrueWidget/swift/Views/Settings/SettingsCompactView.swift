import SwiftUI

struct SettingsCompactView: View {
  @EnvironmentObject private var userSettings: UserSettings

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("Local time")) {
        VStack(alignment: .leading) {
          Toggle(isOn: $userSettings.compactShowLocalTime) {
            Text("Show local time")
          }
          .switchToggleStyle()

          HStack {
            Text("Local time font size:")

            DoubleTextField(
              value: $userSettings.compactLocalTimeFontSize,
              range: 0...1000,
              step: 2,
              maximumFractionDigits: 1,
              width: 40)

            Text("pt")

            Text("(Default: 24 pt)")
          }

          HStack {
            Text("Local time font size for seconds:")

            DoubleTextField(
              value: $userSettings.compactLocalTimeSecondsFontSize,
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

      GroupBox(label: Text("Local date")) {
        VStack(alignment: .leading) {
          Toggle(isOn: $userSettings.compactShowLocalDate) {
            Text("Show local date")
          }
          .switchToggleStyle()

          HStack {
            Text("Local date font size:")

            DoubleTextField(
              value: $userSettings.compactLocalDateFontSize,
              range: 0...1000,
              step: 2,
              maximumFractionDigits: 1,
              width: 40)

            Text("pt")

            Text("(Default: 10 pt)")
          }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      GroupBox(label: Text("CPU Usage")) {
        VStack(alignment: .leading) {
          Toggle(isOn: $userSettings.compactShowCPUUsage) {
            Text("Show CPU usage")
          }
          .switchToggleStyle()
          .padding(.top, 20.0)

          HStack {
            Text("CPU usage font size:")

            DoubleTextField(
              value: $userSettings.compactCPUUsageFontSize,
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

      GroupBox(label: Text("Auto compact")) {
        VStack(alignment: .leading) {
          HStack {
            Text("Automatically switch to compact mode if the display count is ")

            Picker("", selection: $userSettings.autoCompactDisplayCount) {
              ForEach(1...16, id: \.self) { number in
                Text("\(number)").tag(number)
              }
            }
            .frame(width: 60)

            Text("or less")
          }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}
