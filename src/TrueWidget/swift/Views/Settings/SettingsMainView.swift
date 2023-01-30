import SwiftUI

struct SettingsMainView: View {
  @ObservedObject private var userSettings = UserSettings.shared
  @ObservedObject private var openAtLogin = OpenAtLogin.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("Basic")) {
        VStack(alignment: .leading) {
          HStack {
            Toggle(isOn: $userSettings.openAtLogin) {
              Text("Open at login")
            }
            .switchToggleStyle()

            Spacer()
          }

          if openAtLogin.error.count > 0 {
            VStack {
              Label(
                openAtLogin.error,
                systemImage: "exclamationmark.circle.fill"
              )
              .padding()
            }
            .foregroundColor(Color.errorForeground)
            .background(Color.errorBackground)
          }

          HStack {
            Toggle(isOn: $userSettings.showMenu) {
              Text("Show icon in menu bar")
            }
            .switchToggleStyle()

            Spacer()
          }
        }
        .padding()
      }

      GroupBox(label: Text("Widget")) {
        VStack(alignment: .leading) {
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

          HStack {
            Text("Widget opacity: ")

            Slider(
              value: $userSettings.widgetOpacity,
              in: 0.0...1.0,
              step: 0.1,
              minimumValueLabel: Text("Clear"),
              maximumValueLabel: Text("Colored"),
              label: {
                Text("")
              }
            )

            Spacer()
          }

          HStack {
            Picker(
              selection: $userSettings.widgetScreen,
              label: Text("Widget screen when using multiple displays: ")
            ) {
              Text("Primary screen (Default)").tag(WidgetScreen.primary.rawValue)
              Text("Bottom Left screen").tag(WidgetScreen.bottomLeft.rawValue)
              Text("Bottom Right screen").tag(WidgetScreen.bottomRight.rawValue)
              Text("Top Left screen").tag(WidgetScreen.topLeft.rawValue)
              Text("Top Right screen").tag(WidgetScreen.topRight.rawValue)
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

struct SettingsMainView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsMainView()
      .previewLayout(.sizeThatFits)
  }
}
