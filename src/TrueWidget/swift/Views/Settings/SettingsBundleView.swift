import SwiftUI

struct SettingsBundleView: View {
  @EnvironmentObject private var userSettings: UserSettings

  @State var selectedFileURL: URL?

  var body: some View {
    GroupBox(label: Text("Show app versions")) {
      VStack(alignment: .leading) {
        ForEach($userSettings.bundleSettings) { setting in
          HStack {
            Toggle(isOn: setting.show) {
              Text("Show")
            }
            .switchToggleStyle()

            BundlePickerView(selectedFileURL: setting.url)
          }
        }
      }
      .padding()
    }
  }
}
