import SwiftUI

struct SettingsView: View {
  @ObservedObject private var userSettings = UserSettings.shared

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

          HStack {
            Picker(selection: $userSettings.widgetPosition, label: Text("Widget position: ")) {
              Text("Bottom Left").tag(WidgetPosition.bottomLeft.rawValue)
              Text("Bottom Right (Default)").tag(WidgetPosition.bottomRight.rawValue)
              Text("Top Left").tag(WidgetPosition.topLeft.rawValue)
              Text("Top Right").tag(WidgetPosition.topRight.rawValue)
            }

            Spacer()
          }

          HStack {
            Text("Widget width: ")

            DoubleTextField(
              value: $userSettings.widgetWidth,
              range: 0...10000,
              step: 50,
              width: 50)

            Text("pt")

            Text("(Default: 250 pt)")

            Spacer()
          }
        }
        .padding()
      }

      GroupBox(label: Text("Operating system")) {
        VStack(alignment: .leading, spacing: 10.0) {
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
        }
        .padding()
      }

      GroupBox(label: Text("CPU usage")) {
        VStack(alignment: .leading, spacing: 10.0) {
          HStack {
            Toggle(isOn: $userSettings.showCPUUsage) {
              Text("Show CPU usage")
            }

            Spacer()
          }

          HStack {
            Text("Font size: ")

            DoubleTextField(
              value: $userSettings.cpuUsageFontSize,
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

      GroupBox(label: Text("Local time")) {
        VStack(alignment: .leading, spacing: 10.0) {
          HStack {
            Toggle(isOn: $userSettings.showLocalTime) {
              Text("Show local time")
            }

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
    }
    .padding()
    .frame(width: 450)
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
      .previewLayout(.sizeThatFits)
  }
}
