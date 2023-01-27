import Combine
import Foundation

extension WidgetSource {
  public class LocalTime: ObservableObject {
    static let shared = LocalTime()

    @Published public var hour: Int = 0
    @Published public var minute: Int = 0
    @Published public var second: Int = 0
    @Published public var date: String = ""

    private var timer: Timer?

    private init() {
      timer = Timer.scheduledTimer(
        withTimeInterval: 0.5,
        repeats: true
      ) { [weak self] (_: Timer) in
        guard let self = self else { return }

        if !UserSettings.shared.showLocalTime {
          return
        }

        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second, .weekday], from: now)

        if let hour = components.hour {
          if self.hour != hour {
            self.hour = hour
          }
        }

        if let minute = components.minute {
          if self.minute != minute {
            self.minute = minute
          }
        }

        if let second = components.second {
          if self.second != second {
            self.second = second
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
          if self.date != text {
            self.date = "\(date) (\(weekdaySymbol))"
          }
        }
      }
    }
  }
}
