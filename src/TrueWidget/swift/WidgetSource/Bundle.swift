import AsyncAlgorithms
import Combine
import Foundation

extension WidgetSource {
  public class Bundle: ObservableObject {
    private var userSettings: UserSettings

    private var helperConnection: NSXPCConnection?
    private var helperProxy: HelperProtocol?

    @Published public var bundleVersions: [String: [String: String]] = [:]
    let timer: AsyncTimerSequence<ContinuousClock>
    var timerTask: Task<Void, Never>?

    init(userSettings: UserSettings) {
      self.userSettings = userSettings

      timer = AsyncTimerSequence(
        interval: .seconds(3),
        clock: .continuous
      )

      timerTask = Task { @MainActor in
        update()

        for await _ in timer {
          update()
        }
      }
    }

    // Since timerTask strongly references self, make sure to call cancelTimer when Bundle is no longer used.
    func cancelTimer() {
      timerTask?.cancel()
    }

    @MainActor
    private func update() {
      HelperClient.shared.proxy?.bundleVersions(
        paths: userSettings.bundleSettings.filter({ $0.show && $0.url != nil }).map({
          $0.url?.path ?? ""
        })
      ) { versions in
        self.bundleVersions = versions
      }
    }
  }
}
