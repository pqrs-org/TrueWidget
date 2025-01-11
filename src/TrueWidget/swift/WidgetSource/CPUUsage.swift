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

    // Since timerTask strongly references self, make sure to call cancelTimer when CPUUsage is no longer used.
    func cancelTimer() {
      timerTask?.cancel()

      Task { @MainActor in
        HelperClient.shared.proxy?.stopTopCommand()
      }
    }

    @MainActor
    private func update() {
      // To get the CPU utilization of a process (especially kernel_task information),
      // as far as I've been able to find out, we need to use the results of the top command or need administrator privileges.
      // Since the top command has a setuid bit and can be used without privilege, we run top command in a helper process and use the result.

      //
      // CPU Usage
      //

      HelperClient.shared.proxy?.topCommand { cpuUsage, processes in
        Task { @MainActor in
          self.usageInteger = Int(floor(cpuUsage))
          self.usageDecimal = Int(floor((cpuUsage) * 100)) % 100

          //
          // Calculate average
          //

          let averageRange = max(self.userSettings.cpuUsageMovingAverageRange, 1)
          self.usageHistory.append(cpuUsage)
          while self.usageHistory.count > averageRange {
            self.usageHistory.remove(at: 0)
          }

          let usageAverage = self.usageHistory.reduce(0.0, +) / Double(self.usageHistory.count)
          self.usageAverageInteger = Int(floor(usageAverage))
          self.usageAverageDecimal = Int(floor((usageAverage) * 100)) % 100

          //
          // Processes
          //

          var newProcesses = processes
          while newProcesses.count < 3 {
            newProcesses.append([:])
          }
          self.processes = newProcesses
        }
      }
    }
  }
}
