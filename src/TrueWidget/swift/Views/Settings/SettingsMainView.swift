import SwiftUI

struct SettingsMainView: View {
  @Binding var showMenuBarExtra: Bool

  @EnvironmentObject private var userSettings: UserSettings
  @ObservedObject private var openAtLogin = OpenAtLogin.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("Basic")) {
        VStack(alignment: .leading) {
          Toggle(isOn: $openAtLogin.registered) {
            Text("Open at login")
          }
          .switchToggleStyle()
          .disabled(openAtLogin.developmentBinary)
          .onChange(of: openAtLogin.registered) { value in
            OpenAtLogin.shared.update(register: value)
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

          Toggle(isOn: $showMenuBarExtra) {
            Text("Show icon in menu bar")
          }
          .switchToggleStyle()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      GroupBox(label: Text("Widget")) {
        VStack(alignment: .leading) {
          Picker(selection: $userSettings.widgetPosition, label: Text("Widget position:")) {
            Text("Bottom Left").tag(WidgetPosition.bottomLeft.rawValue)
            Text("Bottom Right (Default)").tag(WidgetPosition.bottomRight.rawValue)
            Text("Top Left").tag(WidgetPosition.topLeft.rawValue)
            Text("Top Right").tag(WidgetPosition.topRight.rawValue)
          }

          HStack {
            Text("Widget width:")

            DoubleTextField(
              value: $userSettings.widgetWidth,
              range: 0...10000,
              step: 10,
              maximumFractionDigits: 1,
              width: 50)

            Text("pt")

            Text("(Default: 250 pt)")
          }

          HStack {
            Text("Widget opacity:")

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
          }

          Picker(
            selection: $userSettings.widgetScreen,
            label: Text("Widget screen when using multiple displays:")
          ) {
            Text("Primary screen (Default)").tag(WidgetScreen.primary.rawValue)
            Text("Bottom Left screen").tag(WidgetScreen.bottomLeft.rawValue)
            Text("Bottom Right screen").tag(WidgetScreen.bottomRight.rawValue)
            Text("Top Left screen").tag(WidgetScreen.topLeft.rawValue)
            Text("Top Right screen").tag(WidgetScreen.topRight.rawValue)
            Text("Leftmost (top)").tag(WidgetScreen.leftTop.rawValue)
            Text("Leftmost (bottom)").tag(WidgetScreen.leftBottom.rawValue)
            Text("Rightmost (top)").tag(WidgetScreen.rightTop.rawValue)
            Text("Rightmost (bottom)").tag(WidgetScreen.rightBottom.rawValue)
          }

          HStack {
            Text("Widget fade-out duration:")

            DoubleTextField(
              value: $userSettings.widgetFadeOutDuration,
              range: 0...10000,
              step: 100,
              maximumFractionDigits: 1,
              width: 50)

            Text("milliseconds")

            Text("(Default: 500 ms)")
          }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      GroupBox(label: Text("Appearance")) {
        VStack(alignment: .leading) {
          Picker("", selection: $userSettings.widgetAppearance) {
            Text("Normal").tag(WidgetAppearance.normal.rawValue)
            Text("Compact").tag(WidgetAppearance.compact.rawValue)
            Text("Auto compact").tag(WidgetAppearance.autoCompact.rawValue)
            Text("Hidden").tag(WidgetAppearance.hidden.rawValue)
          }
          .pickerStyle(.radioGroup)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}
