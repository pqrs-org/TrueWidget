import SwiftUI

struct SettingsUTCTimeView: View {
  @ObservedObject private var userSettings = UserSettings.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("UTC time")) {
        VStack(alignment: .leading) {
          HStack {
            Toggle(isOn: $userSettings.showUTCTime) {
              Text("Show UTC time")
            }
            .switchToggleStyle()

            Spacer()
          }

          HStack {
            Text("Font size: ")

            DoubleTextField(
              value: $userSettings.utcTimeFontSize,
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

      Spacer()
    }
  }
}

struct SettingsUTCTimeView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsUTCTimeView()
      .previewLayout(.sizeThatFits)
  }
}
