import AsyncAlgorithms
import Combine
import SwiftUI

extension WidgetSource {
  public class Time: ObservableObject {
    public struct DateTime: Identifiable {
      public let id = UUID()
      public let date: String
      public let hour: Int
      public let minute: Int
      public let second: Int

      init(now: Date, timeZone: TimeZone, dateStyle: DateStyle) {
        let formatter1 = DateFormatter()
        formatter1.locale = Locale.current
        formatter1.timeZone = timeZone

        let formatter2 = DateFormatter()
        formatter2.locale = Locale.current
        formatter2.timeZone = timeZone

        switch dateStyle {
        case .rfc3339:
          formatter1.dateFormat = "yyyy-MM-dd"
          date = formatter1.string(from: now)

        case .rfc3339WithDayName:
          formatter1.dateFormat = "yyyy-MM-dd (EEE)"
          date = formatter1.string(from: now)

        case .short:
          formatter1.dateStyle = .short
          date = formatter1.string(from: now)

        case .shortWithDayName:
          formatter1.dateStyle = .short
          formatter2.dateFormat = " (EEE)"
          date = formatter1.string(from: now) + formatter2.string(from: now)

        case .medium:
          formatter1.dateStyle = .medium
          date = formatter1.string(from: now)

        case .mediumWithDayName:
          formatter1.dateStyle = .medium
          formatter2.dateFormat = " (EEE)"
          date = formatter1.string(from: now) + formatter2.string(from: now)

        case .long:
          formatter1.dateStyle = .long
          date = formatter1.string(from: now)

        case .longWithDayName:
          formatter1.dateStyle = .long
          formatter2.dateFormat = " (EEE)"
          date = formatter1.string(from: now) + formatter2.string(from: now)
        }

        var calendar = Calendar.current
        calendar.timeZone = timeZone

        hour = calendar.component(.hour, from: now)
        minute = calendar.component(.minute, from: now)
        second = calendar.component(.second, from: now)
      }
    }

    private var userSettings: UserSettings

    @Published public var localTime: DateTime?
    @Published public var timeZoneTimes: [String: DateTime] = [:]

    let timer: AsyncTimerSequence<ContinuousClock>
    var timerTask: Task<Void, Never>?

    init(userSettings: UserSettings) {
      self.userSettings = userSettings

      timer = AsyncTimerSequence(
        interval: .seconds(1),
        clock: .continuous
      )

      timerTask = Task { @MainActor in
        update()

        for await _ in timer {
          update()
        }
      }
    }

    // Since timerTask strongly references self, make sure to call cancelTimer when Time is no longer used.
    func cancelTimer() {
      timerTask?.cancel()
    }

    private func update() {
      let now = Date()
      self.updateLocalTime(now)
      self.updateTimeZoneTimes(now)
    }

    private func updateLocalTime(_ now: Date) {
      if !userSettings.showLocalTime && !userSettings.showLocalDate {
        return
      }

      if let dateStyle = DateStyle(rawValue: userSettings.dateStyle) {
        localTime = DateTime(now: now, timeZone: Calendar.current.timeZone, dateStyle: dateStyle)
      }
    }

    private func updateTimeZoneTimes(_ now: Date) {
      var times: [String: DateTime] = [:]

      userSettings.timeZoneTimeSettings.forEach { setting in
        if setting.show && times[setting.abbreviation] == nil {
          if let identifier = TimeZone.abbreviationDictionary[setting.abbreviation] {
            if let timeZone = TimeZone(identifier: identifier) {
              if let dateStyle = DateStyle(rawValue: userSettings.dateStyle) {
                times[setting.abbreviation] = DateTime(
                  now: now, timeZone: timeZone, dateStyle: dateStyle)
              }
            }
          }
        }
      }

      timeZoneTimes = times
    }
  }
}
