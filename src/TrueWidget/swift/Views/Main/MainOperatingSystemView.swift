import SwiftUI

struct MainOperatingSystemView: View {
  @ObservedObject private var userSettings: UserSettings
  @StateObject private var operatingSystem: WidgetSource.OperatingSystem

  init(userSettings: UserSettings) {
    self.userSettings = userSettings
    _operatingSystem = StateObject(
      wrappedValue: WidgetSource.OperatingSystem(userSettings: userSettings))
  }

  var body: some View {
    //
    // Operating system
    //

    VStack(spacing: 0) {
      HStack(alignment: .center, spacing: 0) {
        Text("macOS ")

        Text(operatingSystem.version)

        Spacer()

        if userSettings.showHostName {
          Text(operatingSystem.hostName)
        }
      }

      if userSettings.showRootVolumeName {
        HStack {
          Spacer()

          Text("/Volumes/\(operatingSystem.rootVolumeName)")
        }
      }

      if userSettings.showUserName {
        HStack {
          Spacer()

          Text(operatingSystem.userName)
        }
      }
    }
    .font(.system(size: userSettings.operatingSystemFontSize))
    .onDisappear {
      operatingSystem.cancelTimer()
    }
  }
}
