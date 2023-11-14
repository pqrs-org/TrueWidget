import SwiftUI

enum NavigationTag: String {
  case main
  case operatingSystem
  case xcode
  case cpuUsage
  case time
  case update
  case action
}

struct SettingsView: View {
  @ObservedObject private var userSettings = UserSettings.shared
  @State private var selection: NavigationTag = .main

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 0) {
        Button(
          action: {
            selection = .main
          },
          label: {
            SidebarLabelView(text: "Main", systemImage: "gear")
          }
        )
        .sidebarButtonStyle(selected: selection == .main)

        Button(
          action: {
            selection = .operatingSystem
          },
          label: {
            SidebarLabelView(text: "Layout > Operation System", systemImage: "cube")
          }
        )
        .sidebarButtonStyle(selected: selection == .operatingSystem)

        Button(
          action: {
            selection = .xcode
          },
          label: {
            SidebarLabelView(text: "Layout > Xcode", systemImage: "cube")
          }
        )
        .sidebarButtonStyle(selected: selection == .xcode)

        Button(
          action: {
            selection = .cpuUsage
          },
          label: {
            SidebarLabelView(text: "Layout > CPU Usage", systemImage: "cube")
          }
        )
        .sidebarButtonStyle(selected: selection == .cpuUsage)

        Button(
          action: {
            selection = .time
          },
          label: {
            SidebarLabelView(text: "Layout > Time", systemImage: "cube")
          }
        )
        .sidebarButtonStyle(selected: selection == .time)

        Button(
          action: {
            selection = .update
          },
          label: {
            SidebarLabelView(text: "Update", systemImage: "network")
          }
        )
        .sidebarButtonStyle(selected: selection == .update)

        Divider()
          .padding(.vertical, 10.0)

        Button(
          action: {
            selection = .action
          },
          label: {
            SidebarLabelView(text: "Quit, Restart", systemImage: "bolt.circle")
          }
        )
        .sidebarButtonStyle(selected: selection == .action)

        Spacer()
      }
      .frame(width: 250)

      Divider()

      switch selection {
      case .main:
        SettingsMainView()
      case .operatingSystem:
        SettingsOperatingSystemView()
      case .xcode:
        SettingsXcodeView()
      case .cpuUsage:
        SettingsCPUUsageView()
      case .time:
        SettingsTimeView()
      case .update:
        SettingsUpdateView()
      case .action:
        SettingsActionView()
      }
    }
    .padding()
    .frame(width: 800)
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
      .previewLayout(.sizeThatFits)
  }
}
