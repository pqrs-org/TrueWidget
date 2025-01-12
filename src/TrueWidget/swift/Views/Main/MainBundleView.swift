import SwiftUI

struct MainBundleView: View {
  @ObservedObject private var userSettings: UserSettings
  @StateObject private var bundle: WidgetSource.Bundle

  init(userSettings: UserSettings) {
    self.userSettings = userSettings
    _bundle = StateObject(wrappedValue: WidgetSource.Bundle(userSettings: userSettings))
  }

  var body: some View {
    VStack(alignment: .trailing, spacing: 0) {
      ForEach(userSettings.bundleSettings) { setting in
        if setting.show {
          if let version = bundle.bundleVersions[setting.url?.path ?? ""] {
            Text("\(version["name"] ?? "---"): \(version["version"] ?? "---")")
              .fixedSize(horizontal: false, vertical: true)
              .multilineTextAlignment(.trailing)
          } else {
            Text("---")
          }
        }
      }
    }
    .font(.system(size: userSettings.bundleFontSize))
    .frame(maxWidth: .infinity, alignment: .trailing)
    .onDisappear {
      bundle.cancelTimer()
    }
  }
}
