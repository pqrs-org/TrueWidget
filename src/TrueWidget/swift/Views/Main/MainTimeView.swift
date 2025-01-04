import SwiftUI

struct MainTimeView: View {
  @ObservedObject private var userSettings: UserSettings
  @StateObject private var time: WidgetSource.Time

  init(userSettings: UserSettings) {
    self.userSettings = userSettings
    _time = StateObject(wrappedValue: WidgetSource.Time(userSettings: userSettings))
  }

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

      if userSettings.showLocalTime {
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
      }

      ForEach(userSettings.timeZoneTimeSettings) { setting in
        if setting.show {
          HStack(alignment: .center, spacing: 0) {
            Spacer()

            let timeZoneTime = time.timeZoneTimes[setting.abbreviation]
            Text(
              timeZoneTime == nil
                ? "---"
                : String(
                  format: "%@ %02d:%02d:%02d",
                  setting.abbreviation,
                  timeZoneTime?.hour ?? 0,
                  timeZoneTime?.minute ?? 0,
                  timeZoneTime?.second ?? 0
                )
            )
            .font(.custom("Menlo", size: userSettings.timeZoneTimeFontSize))
          }
        }
      }
    }
  }
}
