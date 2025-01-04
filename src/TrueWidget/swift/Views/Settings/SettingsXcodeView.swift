import SwiftUI

struct SettingsXcodeView: View {
  @EnvironmentObject private var userSettings: UserSettings

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("Xcode")) {
        VStack(alignment: .leading) {
          HStack {
            Toggle(isOn: $userSettings.showXcode) {
              Text("Show Xcode bundle path")
            }
            .switchToggleStyle()

            Spacer()
          }

          HStack {
            Text("Font size: ")

            DoubleTextField(
              value: $userSettings.xcodeFontSize,
              range: 0...1000,
              step: 2,
              maximumFractionDigits: 1,
              width: 40)

            Text("pt")

            Text("(Default: 12 pt)")

            Spacer()
          }
        }.padding()
      }
    }
    .padding()
  }
}
