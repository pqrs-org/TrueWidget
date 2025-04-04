import SwiftUI

struct MainXcodeView: View {
  @ObservedObject private var userSettings: UserSettings
  @StateObject private var xcode: WidgetSource.Xcode

  init(userSettings: UserSettings) {
    self.userSettings = userSettings
    _xcode = StateObject(wrappedValue: WidgetSource.Xcode())
  }

  var body: some View {
    VStack(alignment: .trailing, spacing: 0) {
      Text(xcode.path)
        .foregroundColor(pathColor(xcode.pathState))
    }
    .font(.system(size: userSettings.xcodeFontSize))
    .frame(maxWidth: .infinity, alignment: .trailing)
    .onDisappear {
      xcode.cancelTimer()
    }
  }

  private func pathColor(_ pathState: WidgetSource.Xcode.PathState) -> Color {
    switch pathState {
    case .notInstalled:
      return .gray
    case .defaultPath:
      return .white
    case .nonDefaultPath:
      return .green
    }
  }
}
