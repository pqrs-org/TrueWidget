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
  @State private var selection: NavigationTag = NavigationTag.main

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 0) {
        Button(action: {
          selection = NavigationTag.main
        }) {
          SidebarLabelView(text: "Main", systemImage: "gear")
        }
        .sidebarButtonStyle(selected: selection == NavigationTag.main)

        Button(action: {
          selection = NavigationTag.operatingSystem
        }) {
          SidebarLabelView(text: "Layout > Operation System", systemImage: "cube")
        }
        .sidebarButtonStyle(selected: selection == NavigationTag.operatingSystem)

        Button(action: {
          selection = NavigationTag.xcode
        }) {
          SidebarLabelView(text: "Layout > Xcode", systemImage: "cube")
        }
        .sidebarButtonStyle(selected: selection == NavigationTag.xcode)

        Button(action: {
          selection = NavigationTag.cpuUsage
        }) {
          SidebarLabelView(text: "Layout > CPU Usage", systemImage: "cube")
        }
        .sidebarButtonStyle(selected: selection == NavigationTag.cpuUsage)

        Button(action: {
          selection = NavigationTag.time
        }) {
          SidebarLabelView(text: "Layout > Time", systemImage: "cube")
        }
        .sidebarButtonStyle(selected: selection == NavigationTag.time)

        Button(action: {
          selection = NavigationTag.update
        }) {
          SidebarLabelView(text: "Update", systemImage: "network")
        }
        .sidebarButtonStyle(selected: selection == NavigationTag.update)

        Divider()
          .padding(.vertical, 10.0)

        Button(action: {
          selection = NavigationTag.action
        }) {
          SidebarLabelView(text: "Quit, Restart", systemImage: "bolt.circle")
        }
        .sidebarButtonStyle(selected: selection == NavigationTag.action)

        Spacer()
      }
      .frame(width: 250)

      Divider()

      switch selection {
      case NavigationTag.main:
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
