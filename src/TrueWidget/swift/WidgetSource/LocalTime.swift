import Combine
import Foundation

extension WidgetSource {
  public class LocalTime: ObservableObject {
    static let shared = LocalTime()

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

        if !UserSettings.shared.showLocalTime {
          return
        }

        let now = Date()
        let calendar = Calendar.current

        self.hour = calendar.component(.hour, from: now)
        self.minute = calendar.component(.minute, from: now)
        self.second = calendar.component(.second, from: now)
      }
    }
  }
}
