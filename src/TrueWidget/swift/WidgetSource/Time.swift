import Combine
import Foundation
import SwiftUI

extension WidgetSource {
  public class Time: ObservableObject {
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

    private var userSettings: UserSettings

    @Published public var localTime: DateTime?
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
      let components = calendar.dateComponents(
        [
          .year, .month, .day,
          .hour, .minute, .second,
          .weekday,
        ], from: now)

      localTime = DateTime(components)
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
