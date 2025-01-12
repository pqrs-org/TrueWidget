import SwiftUI

enum TabTag: String {
  case main
  case cpuUsage
  case time
  case operatingSystem
  case xcode
  case bundle
  case update
  case action
}

struct SettingsView: View {
  @Binding var showMenuBarExtra: Bool

  @State private var selection: TabTag = .main

  var body: some View {
    TabView(selection: $selection) {
      SettingsMainView(showMenuBarExtra: $showMenuBarExtra)
        .tabItem {
          Label("Main", systemImage: "gearshape")
        }
        .tag(TabTag.main)

      SettingsCPUUsageView()
        .tabItem {
          Label("CPU", systemImage: "cube")
        }
        .tag(TabTag.cpuUsage)

      SettingsTimeView()
        .tabItem {
          Label("Time", systemImage: "cube")
        }
        .tag(TabTag.time)

      SettingsOperatingSystemView()
        .tabItem {
          Label("System", systemImage: "cube")
        }
        .tag(TabTag.operatingSystem)

      SettingsXcodeView()
        .tabItem {
          Label("Xcode", systemImage: "cube")
        }
        .tag(TabTag.xcode)

      SettingsBundleView()
        .tabItem {
          Label("App", systemImage: "cube")
        }
        .tag(TabTag.bundle)

      SettingsUpdateView()
        .tabItem {
          Label("Update", systemImage: "network")
        }
        .tag(TabTag.update)

      SettingsActionView()
        .tabItem {
          Label("Quit, Restart", systemImage: "bolt.circle")
        }
        .tag(TabTag.action)
    }
    .scenePadding()
    .frame(width: 600)
  }
}
