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

      VStack(alignment: .trailing, spacing: 0) {
        if userSettings.showRootVolumeName {
          Text("/Volumes/\(operatingSystem.rootVolumeName)")
        }

        if userSettings.showUserName {
          Text(operatingSystem.userName)
        }
      }
      .frame(maxWidth: .infinity, alignment: .trailing)
    }
    .font(.system(size: userSettings.operatingSystemFontSize))
    .onDisappear {
      operatingSystem.cancelTimer()
    }
  }
}
