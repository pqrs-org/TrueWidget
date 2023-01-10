import SwiftUI

struct SettingsLocalTimeView: View {
  @ObservedObject private var userSettings = UserSettings.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("Local time")) {
        VStack(alignment: .leading) {
          HStack {
            Toggle(isOn: $userSettings.showLocalTime) {
              Text("Show local time")
            }
            .switchToggleStyle()

            Spacer()
          }

          HStack {
            Text("Font size: ")

            DoubleTextField(
              value: $userSettings.localTimeFontSize,
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

      if userSettings.showLocalTime {
        GroupBox(label: Text("Advanced")) {
          VStack(alignment: .leading) {
            HStack {
              Toggle(isOn: $userSettings.showLocalDate) {
                Text("Show local date")
              }
              .switchToggleStyle()

              Spacer()
            }

            HStack {
              Text("Local date font size: ")

              DoubleTextField(
                value: $userSettings.localDateFontSize,
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

struct SettingsLocalTimeView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsLocalTimeView()
      .previewLayout(.sizeThatFits)
  }
}
