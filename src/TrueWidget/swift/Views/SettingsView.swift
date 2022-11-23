import SwiftUI

struct SettingsView: View {
  let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
  @ObservedObject var userSettings = UserSettings.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("Basic")) {
        VStack(alignment: .leading, spacing: 10.0) {
          HStack {
            Toggle(isOn: $userSettings.openAtLogin) {
              Text("Open at login")
            }

            Spacer()
          }

          HStack {
            Toggle(isOn: $userSettings.showMenu) {
              Text("Show icon in menu bar")
            }

            Spacer()
          }
        }
        .padding()
      }
    }
    .padding()
    .frame(width: 400)
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
      .previewLayout(.sizeThatFits)
  }
}
