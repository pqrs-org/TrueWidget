import Combine
import Foundation
import SwiftUI

extension WidgetSource {
  public struct DateTime: Identifiable {
    public let id = UUID()
    public let date: String
    public let hour: Int
    public let minute: Int
    public let second: Int

    init(_ components: DateComponents) {
      let weekdaySymbol = Calendar.current.shortWeekdaySymbols[(components.weekday ?? 1) - 1]

      date = String(
        format: "%04d-%02d-%02d (%@)",
        components.year ?? 0,
        components.month ?? 0,
        components.day ?? 0,
        weekdaySymbol
      )

      hour = components.hour ?? 0
      minute = components.minute ?? 0
      second = components.second ?? 0
    }
  }

  public class Time: ObservableObject {
    private var userSettings: UserSettings

    @Published public var localHour: Int = 0
    @Published public var localMinute: Int = 0
    @Published public var localSecond: Int = 0
    @Published public var localDate: String = ""

    @Published public var timeZoneTimes: [String: DateTime] = [:]

    private var timer: Timer?

    init(userSettings: UserSettings) {
      self.userSettings = userSettings

      timer = Timer.scheduledTimer(
        withTimeInterval: 1.0,
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
      let calendar = Calendar.current
      var times: [String: DateTime] = [:]

      userSettings.timeZoneTimeSettings.forEach { setting in
        if setting.show && times[setting.abbreviation] == nil {
          if let identifier = TimeZone.abbreviationDictionary[setting.abbreviation] {
            if let timeZone = TimeZone(identifier: identifier) {
              let components = calendar.dateComponents(in: timeZone, from: now)

              times[setting.abbreviation] = DateTime(components)
            }
          }
        }
      }

      timeZoneTimes = times
    }
  }
}
