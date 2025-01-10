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
