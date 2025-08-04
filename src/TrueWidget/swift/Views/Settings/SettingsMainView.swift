import SwiftUI

struct SettingsMainView: View {
  @Binding var showMenuBarExtra: Bool

  @EnvironmentObject private var userSettings: UserSettings
  @ObservedObject private var openAtLogin = OpenAtLogin.shared

  private let windowLevels: [(String, Int)] = [
    ("normal", NSWindow.Level.normal.rawValue),  // 0
    ("floating", NSWindow.Level.floating.rawValue),  // 3
    ("modalPanel", NSWindow.Level.modalPanel.rawValue),  // 8
    ("mainMenu", NSWindow.Level.mainMenu.rawValue),  // 24
    ("statusBar (Default)", NSWindow.Level.statusBar.rawValue),  // 25
    ("popUpMenu", NSWindow.Level.popUpMenu.rawValue),  // 101
    ("screenSaver", NSWindow.Level.screenSaver.rawValue),  // 1000
    // ("submenu", NSWindow.Level.submenu.rawValue), // == floating
    // ("tornOffMenu", NSWindow.Level.tornOffMenu.rawValue), // == floating
  ]

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

          if !openAtLogin.error.isEmpty {
            Label(
              openAtLogin.error,
              systemImage: ErrorBorder.icon
            )
            .modifier(ErrorBorder())
          }

          Toggle(isOn: $showMenuBarExtra) {
            Text("Show icon in menu bar")
          }
          .switchToggleStyle()

          Picker(selection: $userSettings.widgetAppearance, label: Text("Appearance:")) {
            Text("Normal").tag(WidgetAppearance.normal.rawValue)
            Text("Compact").tag(WidgetAppearance.compact.rawValue)
            Text("Auto compact").tag(WidgetAppearance.autoCompact.rawValue)
            Text("Hidden").tag(WidgetAppearance.hidden.rawValue)
          }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      GroupBox(label: Text("Widget")) {
        VStack(alignment: .leading) {
          HStack(alignment: .top) {
            Text("Widget position:")

            VStack(alignment: .leading) {
              Picker(selection: $userSettings.widgetPosition, label: Text("Widget position:")) {
                Text("Bottom Left").tag(WidgetPosition.bottomLeft.rawValue)
                Text("Bottom Right (Default)").tag(WidgetPosition.bottomRight.rawValue)
                Text("Top Left").tag(WidgetPosition.topLeft.rawValue)
                Text("Top Right").tag(WidgetPosition.topRight.rawValue)
              }
              .labelsHidden()

              Toggle(isOn: $userSettings.widgetAllowOverlappingWithDock) {
                Text("Allow overlapping with Dock")
              }
              .switchToggleStyle()

              Picker(selection: $userSettings.widgetWindowLevel, label: Text("Window level:")) {
                ForEach(windowLevels, id: \.0) { level in
                  Text("\(level.0): \(level.1)").tag(level.1)
                }
              }
              Text(
                "The higher the window level number, the more frontmost the window will appear"
              )
              .font(.caption)

              Grid(alignment: .leadingFirstTextBaseline) {
                GridRow {
                  Text("Offset X:")

                  DoubleTextField(
                    value: $userSettings.widgetOffsetX,
                    range: -10000...10000,
                    step: 10,
                    maximumFractionDigits: 1,
                    width: 50)

                  Text("pt")

                  Text("(Default: 10 pt)")
                }

                GridRow {
                  Text("Offset Y:")

                  DoubleTextField(
                    value: $userSettings.widgetOffsetY,
                    range: -10000...10000,
                    step: 10,
                    maximumFractionDigits: 1,
                    width: 50)

                  Text("pt")

                  Text("(Default: 10 pt)")
                }
              }
            }
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
    }
  }
}
