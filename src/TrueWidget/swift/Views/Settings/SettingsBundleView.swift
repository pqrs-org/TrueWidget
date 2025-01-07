import SwiftUI

struct SettingsBundleView: View {
  @EnvironmentObject private var userSettings: UserSettings

  @State var selectedFileURL: URL?

  var body: some View {
    GroupBox(label: Text("Show bundle versions")) {
      VStack(alignment: .leading) {
        ForEach($userSettings.bundleSettings) { setting in
          HStack {
            Toggle(isOn: setting.show) {
              Text("Show")
            }
            .switchToggleStyle()
            .disabled(setting.url.wrappedValue == nil)

            BundlePickerView(selectedFileURL: setting.url)
          }
        }
      }
      .padding()
    }
  }
}
