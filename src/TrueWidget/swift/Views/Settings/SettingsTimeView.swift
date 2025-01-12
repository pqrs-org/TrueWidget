import SwiftUI

struct SettingsTimeView: View {
  @EnvironmentObject private var userSettings: UserSettings

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("Local time")) {
        VStack(alignment: .leading) {
          Toggle(isOn: $userSettings.showLocalTime) {
            Text("Show local time")
          }
          .switchToggleStyle()
          .frame(maxWidth: .infinity, alignment: .leading)

          HStack {
            Text("Font size: ")

            DoubleTextField(
              value: $userSettings.localTimeFontSize,
              range: 0...1000,
              step: 2,
              maximumFractionDigits: 1,
              width: 40)

            Text("pt")

            Text("(Default: 36 pt)")
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
      }

      GroupBox(label: Text("Local date")) {
        VStack(alignment: .leading) {
          Toggle(isOn: $userSettings.showLocalDate) {
            Text("Show local date")
          }
          .switchToggleStyle()
          .frame(maxWidth: .infinity, alignment: .leading)

          HStack {
            Text("Local date font size: ")

            DoubleTextField(
              value: $userSettings.localDateFontSize,
              range: 0...1000,
              step: 2,
              maximumFractionDigits: 1,
              width: 40)

            Text("pt")

            Text("(Default: 12 pt)")
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
      }

      GroupBox(label: Text("Other time zones")) {
        VStack(alignment: .leading) {
          ForEach($userSettings.timeZoneTimeSettings) { timeZoneTimeSetting in
            HStack {
              Toggle(isOn: timeZoneTimeSetting.show) {
                Text("Show")
              }
              .switchToggleStyle()

              TimeZonePickerView(abbreviation: timeZoneTimeSetting.abbreviation)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }

          Divider()

          Grid(alignment: .leadingFirstTextBaseline) {
            GridRow {
              Text("Date font size: ")
                .gridColumnAlignment(.trailing)

              DoubleTextField(
                value: $userSettings.timeZoneDateFontSize,
                range: 0...1000,
                step: 2,
                maximumFractionDigits: 1,
                width: 40)

              Text("pt")

              Text("(Default: 10 pt)")
            }

            GridRow {
              Text("Time font size: ")

              DoubleTextField(
                value: $userSettings.timeZoneTimeFontSize,
                range: 0...1000,
                step: 2,
                maximumFractionDigits: 1,
                width: 40)

              Text("pt")

              Text("(Default: 12 pt)")
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
      }
    }
  }
}
