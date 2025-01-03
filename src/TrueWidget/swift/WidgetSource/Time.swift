import Combine
import Foundation
import SwiftUI

extension WidgetSource {
  public struct TimeZoneTime: Equatable, Identifiable {
    public let id = UUID()
    var hour: Int = 0
    var minute: Int = 0
    var second: Int = 0

    init(time: Date, abbreviation: String) {
      if let identifier = TimeZone.abbreviationDictionary[abbreviation] {
        if let timeZone = TimeZone(identifier: identifier) {
          let calendar = Calendar.current
          let components = calendar.dateComponents(in: timeZone, from: time)

          if let h = components.hour {
            hour = h
          }

          if let m = components.minute {
            minute = m
          }

          if let s = components.second {
            second = s
          }
        }
      }
    }

    public static func == (lhs: TimeZoneTime, rhs: TimeZoneTime) -> Bool {
      return lhs.hour == rhs.hour && lhs.minute == rhs.minute && lhs.second == rhs.second
    }
  }

  public class Time: ObservableObject {
    private var userSettings: UserSettings

    @Published public var localHour: Int = 0
    @Published public var localMinute: Int = 0
    @Published public var localSecond: Int = 0
    @Published public var localDate: String = ""

    @Published public var timeZoneTimes: [String: TimeZoneTime] = [:]

    private var timer: Timer?

    init(userSettings: UserSettings) {
      self.userSettings = userSettings

      timer = Timer.scheduledTimer(
        withTimeInterval: 0.5,
        repeats: true
      ) { [weak self] (_: Timer) in
        guard let self = self else { return }

        let now = Date()
        self.updateLocalTime(now)
        self.updateTimeZoneTimes(now)
      }
    }

    private func updateLocalTime(_ now: Date) {
      if !userSettings.showLocalTime {
        return
      }

      let calendar = Calendar.current
      let components = calendar.dateComponents([.hour, .minute, .second, .weekday], from: now)

      if let hour = components.hour {
        if localHour != hour {
          localHour = hour
        }
      }

      if let minute = components.minute {
        if localMinute != minute {
          localMinute = minute
        }
      }

      if let second = components.second {
        if localSecond != second {
          localSecond = second
        }
      }

      if let weekday = components.weekday {
        let date = ISO8601DateFormatter.string(
          from: now,
          timeZone: TimeZone.current,
          formatOptions: .withFullDate
        )
        let weekdaySymbol = calendar.shortWeekdaySymbols[weekday - 1]
        let text = "\(date) (\(weekdaySymbol))"
        if localDate != text {
          localDate = "\(date) (\(weekdaySymbol))"
        }
      }
    }

    private func updateTimeZoneTimes(_ now: Date) {
      var times: [String: TimeZoneTime] = [:]

      userSettings.timeZoneTimeSettings.forEach { setting in
        if setting.show && times[setting.abbreviation] == nil {
          times[setting.abbreviation] = TimeZoneTime(time: now, abbreviation: setting.abbreviation)
        }
      }

      if timeZoneTimes != times {
        timeZoneTimes = times
      }
    }
  }
}
