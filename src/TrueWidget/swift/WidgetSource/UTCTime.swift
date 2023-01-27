import Combine
import Foundation

extension WidgetSource {
  public class UTCTime: ObservableObject {
    static let shared = UTCTime()

    @Published public var hour: Int = 0
    @Published public var minute: Int = 0
    @Published public var second: Int = 0

    private var timer: Timer?

    private init() {
      timer = Timer.scheduledTimer(
        withTimeInterval: 0.5,
        repeats: true
      ) { [weak self] (_: Timer) in
        guard let self = self else { return }

        if !UserSettings.shared.showUTCTime {
          return
        }

        let now = Date()
        let calendar = Calendar.current
        if let timeZone = TimeZone(identifier: "GMT") {
          let components = calendar.dateComponents(in: timeZone, from: now)

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
        }
      }
    }
  }
}
