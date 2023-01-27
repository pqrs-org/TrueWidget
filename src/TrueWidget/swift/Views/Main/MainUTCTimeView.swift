import SwiftUI

struct MainUTCTimeView: View {
  @ObservedObject private var userSettings = UserSettings.shared
  @ObservedObject private var utcTime = WidgetSource.UTCTime.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .center, spacing: 0) {
        Spacer()

        HStack(alignment: .firstTextBaseline, spacing: 0) {
          Text(
            String(
              format: "UTC %02d:%02d:%02d",
              utcTime.hour,
              utcTime.minute,
              utcTime.second
            )
          )
          .font(.custom("Menlo", size: userSettings.utcTimeFontSize))
        }
      }
    }
  }
}

struct MainUTCTimeView_Previews: PreviewProvider {
  static var previews: some View {
    MainUTCTimeView()
      .previewLayout(.sizeThatFits)
  }
}
