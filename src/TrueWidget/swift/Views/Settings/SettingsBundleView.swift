import SwiftUI

struct SettingsBundleView: View {
  @EnvironmentObject private var userSettings: UserSettings

  @State var selectedFileURL: URL?

  var body: some View {
    GroupBox(label: Text("Show app versions")) {
      VStack(alignment: .leading, spacing: 12.0) {
        ForEach($userSettings.bundleSettings) { setting in
          HStack {
            Toggle(isOn: setting.show) {
              Text("Show")
            }
            .switchToggleStyle()

            BundlePickerView(selectedFileURL: setting.url)
          }
        }

        Divider()

        HStack {
          Text("Font size: ")

          DoubleTextField(
            value: $userSettings.bundleFontSize,
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
