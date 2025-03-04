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

    typealias ProxyResponse = [String: [String: String]]

    private let proxyResponseStream: AsyncStream<ProxyResponse>
    private let proxyResponseContinuation: AsyncStream<ProxyResponse>.Continuation
    private var proxyResponseTask: Task<Void, Never>?

    init(userSettings: UserSettings) {
      self.userSettings = userSettings

      timer = AsyncTimerSequence(
        interval: .seconds(3),
        clock: .continuous
      )

      var continuation: AsyncStream<ProxyResponse>.Continuation!
      proxyResponseStream = AsyncStream { continuation = $0 }
      proxyResponseContinuation = continuation

      timerTask = Task { @MainActor in
        update()

        for await _ in timer {
          update()
        }
      }

      proxyResponseTask = Task { @MainActor in
        // When resuming from sleep or in similar situations,
        // responses from the proxy may be called consecutively within a short period.
        // To avoid frequent UI updates in such cases, throttle is used to control the update frequency.
        for await versions in proxyResponseStream._throttle(
          for: .seconds(1), latest: true)
        {
          bundleVersions = versions
        }
      }
    }

    // Since timerTask strongly references self, make sure to call cancelTimer when Bundle is no longer used.
    func cancelTimer() {
      timerTask?.cancel()
      proxyResponseTask?.cancel()
    }

    @MainActor
    private func update() {
      HelperClient.shared.proxy?.bundleVersions(
        paths: userSettings.bundleSettings.filter({ $0.show && !$0.path.isEmpty }).map({ $0.path })
      ) { versions in
        self.proxyResponseContinuation.yield(versions)
      }
    }
  }
}
