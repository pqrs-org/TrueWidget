import SwiftUI

struct SettingsXcodeView: View {
  @ObservedObject private var userSettings = UserSettings.shared

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
              width: 40)

            Text("pt")

            Text("(Default: 14 pt)")

            Spacer()
          }
        }.padding()
      }

      Spacer()
    }
  }
}

struct SettingsXcodeView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsXcodeView()
      .previewLayout(.sizeThatFits)
  }
}
