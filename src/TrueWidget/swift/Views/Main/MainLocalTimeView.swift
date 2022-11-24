import SwiftUI

struct MainLocalTimeView: View {
  @ObservedObject private var userSettings = UserSettings.shared
  @ObservedObject private var localTime = WidgetSource.LocalTime.shared

  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      Spacer()

      HStack(alignment: .firstTextBaseline, spacing: 0) {
        Text(
          String(
            format: " %02d:%02d",
            localTime.hour,
            localTime.minute
          )
        )
        .font(.custom("Menlo", size: userSettings.localTimeFontSize))

        Text(
          String(
            format: " %02d",
            localTime.second
          )
        )
        .font(.custom("Menlo", size: userSettings.localTimeFontSize / 2))
      }
    }
  }
}

struct MainLocalTimeView_Previews: PreviewProvider {
  static var previews: some View {
    MainLocalTimeView()
      .previewLayout(.sizeThatFits)
  }
}
