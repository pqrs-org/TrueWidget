import SwiftUI

struct SettingsOperatingSystemView: View {
  @EnvironmentObject private var userSettings: UserSettings

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("Operating system")) {
        VStack(alignment: .leading) {
          HStack {
            Toggle(isOn: $userSettings.showOperatingSystem) {
              Text("Show macOS version")
            }
            .switchToggleStyle()

            Spacer()
          }

          HStack {
            Text("Font size: ")

            DoubleTextField(
              value: $userSettings.operatingSystemFontSize,
              range: 0...1000,
              step: 2,
              maximumFractionDigits: 1,
              width: 40)

            Text("pt")

            Text("(Default: 14 pt)")

            Spacer()
          }
        }.padding()
      }

      if userSettings.showOperatingSystem {
        GroupBox(label: Text("Advanced")) {
          VStack(alignment: .leading) {
            HStack {
              Toggle(isOn: $userSettings.showHostName) {
                Text("Show host name")
              }
              .switchToggleStyle()

              Spacer()
            }

            HStack {
              Toggle(isOn: $userSettings.showRootVolumeName) {
                Text("Show root volume name")
              }
              .switchToggleStyle()

              Spacer()
            }

            HStack {
              Toggle(isOn: $userSettings.showUserName) {
                Text("Show user name")
              }
              .switchToggleStyle()

              Spacer()
            }
          }
          .padding()
        }
      }
    }
  }
}
