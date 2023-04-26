import SwiftUI

struct MainOperatingSystemView: View {
  @ObservedObject private var userSettings = UserSettings.shared
  @ObservedObject private var operatingSystem = WidgetSource.OperatingSystem.shared

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
  }
}

struct MainOperatingSystemView_Previews: PreviewProvider {
  static var previews: some View {
    MainOperatingSystemView()
      .previewLayout(.sizeThatFits)
  }
}
