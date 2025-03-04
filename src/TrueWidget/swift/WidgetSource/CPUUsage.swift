import AsyncAlgorithms
import Combine
import Foundation

extension WidgetSource {
  public class CPUUsage: ObservableObject {
    private var userSettings: UserSettings

    @Published public var usageInteger: Int = 0
    @Published public var usageDecimal: Int = 0

    @Published public var usageAverageInteger: Int = 0
    @Published public var usageAverageDecimal: Int = 0

    private var usageHistory: [Double] = []

    @Published public var processes: [[String: String]] = [[:], [:], [:]]

    private let timer: AsyncTimerSequence<ContinuousClock>
    private var timerTask: Task<Void, Never>?

    typealias ProxyResponse = (Double, [[String: String]])

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
        for await (responseCPUUsage, responseProcesses) in proxyResponseStream._throttle(
          for: .seconds(1), latest: true)
        {
          usageInteger = Int(floor(responseCPUUsage))
          usageDecimal = Int(floor((responseCPUUsage) * 100)) % 100

          //
          // Calculate average
          //

          let averageRange = max(userSettings.cpuUsageMovingAverageRange, 1)
          usageHistory.append(responseCPUUsage)
          while usageHistory.count > averageRange {
            usageHistory.remove(at: 0)
          }

          let usageAverage = usageHistory.reduce(0.0, +) / Double(usageHistory.count)
          usageAverageInteger = Int(floor(usageAverage))
          usageAverageDecimal = Int(floor((usageAverage) * 100)) % 100

          //
          // Processes
          //

          var newProcesses = responseProcesses
          while newProcesses.count < 3 {
            newProcesses.append([:])
          }
          processes = newProcesses
        }
      }
    }

    // Since timerTask strongly references self, make sure to call cancelTimer when CPUUsage is no longer used.
    func cancelTimer() {
      timerTask?.cancel()
      proxyResponseTask?.cancel()

      Task { @MainActor in
        HelperClient.shared.proxy?.stopTopCommand()
      }
    }

    @MainActor
    private func update() {
      // To get the CPU utilization of a process (especially kernel_task information),
      // as far as I've been able to find out, we need to use the results of the top command or need administrator privileges.
      // Since the top command has a setuid bit and can be used without privilege, we run top command in a helper process and use the result.

      HelperClient.shared.proxy?.topCommand { cpuUsage, processes in
        self.proxyResponseContinuation.yield((cpuUsage, processes))
      }
    }
  }
}
