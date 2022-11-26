import SwiftUI

struct SettingsOperatingSystemView: View {
  @ObservedObject private var userSettings = UserSettings.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("Operating system")) {
        VStack(alignment: .leading) {
          HStack {
            Toggle(isOn: $userSettings.showOperatingSystem) {
              Text("Show macOS version")
            }

            Spacer()
          }

          HStack {
            Text("Font size: ")

            DoubleTextField(
              value: $userSettings.operatingSystemFontSize,
              range: 0...1000,
              step: 2,
              width: 40)

            Text("pt")

            Text("(Default: 14 pt)")

            Spacer()
          }
        }.padding()
      }

      GroupBox(label: Text("Advanced")) {
        VStack(alignment: .leading) {
          HStack {
            Toggle(isOn: $userSettings.showHostName) {
              Text("Show host name")
            }

            Spacer()
          }
        }
        .padding()
      }

      Spacer()
    }
  }
}

struct SettingsOperatingSystemView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsOperatingSystemView()
      .previewLayout(.sizeThatFits)
  }
}
