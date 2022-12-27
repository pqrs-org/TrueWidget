import SwiftUI

struct MainXcodeView: View {
  @ObservedObject private var userSettings = UserSettings.shared
  @ObservedObject private var xcode = WidgetSource.Xcode.shared

  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      Spacer()

      Text(xcode.path)
        .foregroundColor(pathColor(xcode.pathState))
    }
    .font(.system(size: userSettings.xcodeFontSize))
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

struct MainXcodeView_Previews: PreviewProvider {
  static var previews: some View {
    MainXcodeView()
      .previewLayout(.sizeThatFits)
  }
}
