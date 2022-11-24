import SwiftUI

struct SettingsMainView: View {
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
              step: 10,
              width: 50)

            Text("pt")

            Text("(Default: 250 pt)")

            Spacer()
          }
        }
        .padding()
      }

      Spacer()
    }
  }
}

struct SettingsMainView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsMainView()
      .previewLayout(.sizeThatFits)
  }
}
