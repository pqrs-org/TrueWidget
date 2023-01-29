import SwiftUI

struct MainTimeView: View {
  @ObservedObject private var userSettings = UserSettings.shared
  @ObservedObject private var time = WidgetSource.Time.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if userSettings.showLocalDate {
        HStack(alignment: .center, spacing: 0) {
          Spacer()

          Text(time.localDate)
        }
        .font(.custom("Menlo", size: userSettings.localDateFontSize))
        .padding(.bottom, 4.0)
      }

      HStack(alignment: .center, spacing: 0) {
        Spacer()

        HStack(alignment: .firstTextBaseline, spacing: 0) {
          Text(
            String(
              format: " %02d:%02d",
              time.localHour,
              time.localMinute
            )
          )
          .font(.custom("Menlo", size: userSettings.localTimeFontSize))

          Text(
            String(
              format: " %02d",
              time.localSecond
            )
          )
          .font(.custom("Menlo", size: userSettings.localTimeFontSize / 2))
        }
      }

      ForEach(time.timeZoneTimes) { timeZoneTime in
        HStack(alignment: .center, spacing: 0) {
          Spacer()

          Text(
            String(
              format: "%@ %02d:%02d:%02d",
              timeZoneTime.abbreviation,
              timeZoneTime.hour,
              timeZoneTime.minute,
              timeZoneTime.second
            )
          )
          .font(.custom("Menlo", size: userSettings.timeZoneTimeFontSize))
        }
      }
    }
  }
}

struct MainTimeView_Previews: PreviewProvider {
  static var previews: some View {
    MainTimeView()
      .previewLayout(.sizeThatFits)
  }
}
