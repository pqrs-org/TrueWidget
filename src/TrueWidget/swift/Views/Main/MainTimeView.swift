import SwiftUI

struct MainTimeView: View {
  @ObservedObject private var userSettings: UserSettings
  @StateObject private var time: WidgetSource.Time

  init(userSettings: UserSettings) {
    self.userSettings = userSettings
    _time = StateObject(wrappedValue: WidgetSource.Time(userSettings: userSettings))
  }

  static func isVisible(for userSettings: UserSettings) -> Bool {
    return userSettings.showLocalDate
      || userSettings.showLocalTime
      || !userSettings.timeZoneTimeSettings.filter({ $0.show }).isEmpty
  }

  var body: some View {
    VStack(alignment: .trailing, spacing: 0) {
      if userSettings.showLocalDate {
        Text(time.localTime?.date ?? "---")
          .font(.custom("Menlo", size: userSettings.localDateFontSize))
          .padding(.bottom, 4.0)
      }

      if userSettings.showLocalTime {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
          if userSettings.localTimeFontSize > 0 {
            Text(
              time.localTime == nil
                ? "---"
                : String(
                  format: " %02d:%02d",
                  time.localTime?.hour ?? 0,
                  time.localTime?.minute ?? 0
                )
            )
            .font(.custom("Menlo", size: userSettings.localTimeFontSize))
          }

          if userSettings.localTimeSecondsFontSize > 0 {
            Text(
              time.localTime == nil
                ? "---"
                : String(
                  format: " %02d",
                  time.localTime?.second ?? 0
                )
            )
            .font(.custom("Menlo", size: userSettings.localTimeSecondsFontSize))
          }
        }
      }

      ForEach(userSettings.timeZoneTimeSettings) { setting in
        if setting.show {
          HStack(alignment: .firstTextBaseline, spacing: 0) {
            let dateTime = time.timeZoneTimes[setting.abbreviation]

            Text(String(format: "%@: ", setting.abbreviation))
              .font(.custom("Menlo", size: userSettings.timeZoneTimeFontSize))

            if userSettings.timeZoneDateFontSize > 0 {
              Text(String(format: "%@ ", dateTime?.date ?? "---"))
                .font(.custom("Menlo", size: userSettings.timeZoneDateFontSize))
            }

            if userSettings.timeZoneTimeFontSize > 0 {
              Text(
                dateTime == nil
                  ? "---"
                  : String(
                    format: "%02d:%02d:%02d",
                    dateTime?.hour ?? 0,
                    dateTime?.minute ?? 0,
                    dateTime?.second ?? 0)
              )
              .font(.custom("Menlo", size: userSettings.timeZoneTimeFontSize))
            }
          }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .trailing)
    .onDisappear {
      time.cancelTimer()
    }
  }
}
