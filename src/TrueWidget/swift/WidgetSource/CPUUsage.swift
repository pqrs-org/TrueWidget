import Combine
import Foundation

extension WidgetSource {
  public class CPUUsage: ObservableObject {
    static let shared = CPUUsage()

    @Published public var usageInteger: Int = 0
    @Published public var usageDecimal: Int = 0

    @Published public var usageAverageInteger: Int = 0
    @Published public var usageAverageDecimal: Int = 0

    private var usageHistory: [Double] = []

    @Published public var processes: [[String: String]] = HelperProcessesInitialValue

    // To get the CPU utilization of a process (especially kernel_task information),
    // as far as I've been able to find out, we need to use the results of the top command or need administrator privileges.
    // Since the top command has a setuid bit and can be used without privilege, we run top command in a helper process and use the result.

    private var helperConnection: NSXPCConnection?
    private var helperProxy: HelperProtocol?

    private var timer: Timer?

    private init() {
      timer = Timer.scheduledTimer(
        withTimeInterval: 1.0,
        repeats: true
      ) { [weak self] (_: Timer) in
        guard let self = self else { return }

        self.update()
      }
    }

    private func update() {
      if !UserSettings.shared.showCPUUsage {
        helperProxy = nil
        helperConnection = nil
        return
      }

      if helperConnection == nil {
        helperConnection = NSXPCConnection(serviceName: "org.pqrs.TrueWidget.Helper")
        helperConnection?.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
        helperConnection?.resume()
      }

      if helperProxy == nil {
        helperProxy = helperConnection?.remoteObjectProxy as? HelperProtocol
      }

      //
      // CPU Usage
      //

      helperProxy?.cpuUsage { [weak self] cpuUsage in
        guard let self = self else { return }

        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }

          self.usageInteger = Int(floor(cpuUsage))
          self.usageDecimal = Int(floor((cpuUsage) * 100)) % 100

          //
          // Calculate average
          //

          let averageRange = max(UserSettings.shared.cpuUsageMovingAverageRange, 1)
          self.usageHistory.append(cpuUsage)
          while self.usageHistory.count > averageRange {
            self.usageHistory.remove(at: 0)
          }

          let usageAverage = self.usageHistory.reduce(0.0, +) / Double(self.usageHistory.count)
          self.usageAverageInteger = Int(floor(usageAverage))
          self.usageAverageDecimal = Int(floor((usageAverage) * 100)) % 100
        }
      }

      //
      // Processes
      //

      helperProxy?.processes { [weak self] processes in
        guard let self = self else { return }

        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }

          self.processes = processes
        }
      }
    }
  }
}
