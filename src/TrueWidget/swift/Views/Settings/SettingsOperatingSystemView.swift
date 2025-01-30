import SwiftUI

struct SettingsOperatingSystemView: View {
  @EnvironmentObject private var userSettings: UserSettings

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("Operating system")) {
        VStack(alignment: .leading) {
          Toggle(isOn: $userSettings.showOperatingSystem) {
            Text("Show macOS version")
          }
          .switchToggleStyle()

          HStack {
            Text("Font size:")

            DoubleTextField(
              value: $userSettings.operatingSystemFontSize,
              range: 0...1000,
              step: 2,
              maximumFractionDigits: 1,
              width: 40)

            Text("pt")

            Text("(Default: 14 pt)")
          }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      if userSettings.showOperatingSystem {
        GroupBox(label: Text("Advanced")) {
          VStack(alignment: .leading) {
            Toggle(isOn: $userSettings.showUptime) {
              Text("Show uptime")
            }
            .switchToggleStyle()

            Toggle(isOn: $userSettings.showAwakeTime) {
              Text("Show awake time")
            }
            .switchToggleStyle()

            Toggle(isOn: $userSettings.showHostName) {
              Text("Show host name")
            }
            .switchToggleStyle()

            Toggle(isOn: $userSettings.showRootVolumeName) {
              Text("Show root volume name")
            }
            .switchToggleStyle()

            Toggle(isOn: $userSettings.showUserName) {
              Text("Show user name")
            }
            .switchToggleStyle()

            Toggle(isOn: $userSettings.showAppleAccount) {
              Text("Show Apple Account")
            }
            .switchToggleStyle()
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
  }
}
