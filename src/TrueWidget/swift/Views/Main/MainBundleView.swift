import SwiftUI

struct MainBundleView: View {
  @ObservedObject private var userSettings: UserSettings
  @StateObject private var bundle: WidgetSource.Bundle

  init(userSettings: UserSettings) {
    self.userSettings = userSettings
    _bundle = StateObject(wrappedValue: WidgetSource.Bundle(userSettings: userSettings))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Grid(alignment: .trailing) {
        ForEach(userSettings.bundleSettings) { setting in
          if setting.show {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
              Spacer()

              if setting.show {
                if let version = bundle.bundleVersions[setting.url?.path ?? ""] {
                  Text("\(version.name): \(version.version)")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.trailing)
                } else {
                  Text("---")
                }
              }
            }
          }
        }
      }
    }
    .font(.system(size: userSettings.bundleFontSize))
    .onDisappear {
      bundle.cancelTimer()
    }
  }
}
