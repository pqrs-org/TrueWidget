import Combine
import Foundation

extension WidgetSource {
  public class CPUUsage: ObservableObject {
    static let shared = CPUUsage()

    @Published public var user: Double = 0.0
    @Published public var system: Double = 0.0
    @Published public var idle: Double = 0.0
    @Published public var nice: Double = 0.0

    @Published public var usageInteger: Int = 0
    @Published public var usageDecimal: Int = 0

    @Published public var usageAverageInteger: Int = 0
    @Published public var usageAverageDecimal: Int = 0

    private var usageHistory: [Double] = []

    private let host = mach_host_self()
    private var previousLoad: host_cpu_load_info
    private var timer: Timer?

    private init() {
      previousLoad = host_cpu_load_info()

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
        return
      }

      var count = mach_msg_type_number_t(
        MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
      let hostInfo = host_cpu_load_info_t.allocate(capacity: 1)

      let _ = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        (pointer) -> kern_return_t in
        return host_statistics(host, HOST_CPU_LOAD_INFO, pointer, &count)
      }

      let load = hostInfo.move()
      hostInfo.deallocate()

      let userTicks = Double(load.cpu_ticks.0 - previousLoad.cpu_ticks.0)
      let systemTicks = Double(load.cpu_ticks.1 - previousLoad.cpu_ticks.1)
      let idleTicks = Double(load.cpu_ticks.2 - previousLoad.cpu_ticks.2)
      let niceTicks = Double(load.cpu_ticks.3 - previousLoad.cpu_ticks.3)
      let totalTicks = userTicks + systemTicks + idleTicks + niceTicks

      if totalTicks > 0 {
        user = 100.0 * userTicks / totalTicks
        system = 100.0 * systemTicks / totalTicks
        idle = 100.0 * idleTicks / totalTicks
        nice = 100.0 * niceTicks / totalTicks

        usageInteger = Int(floor(user + system))
        usageDecimal = Int(floor((user + system) * 100)) % 100

        //
        // Calculate average
        //

        let averageRange = max(UserSettings.shared.cpuUsageMovingAverageRange, 1)
        usageHistory.append(user + system)
        while usageHistory.count > averageRange {
          usageHistory.remove(at: 0)
        }

        let usageAverage = usageHistory.reduce(0.0, +) / Double(usageHistory.count)
        usageAverageInteger = Int(floor(usageAverage))
        usageAverageDecimal = Int(floor((usageAverage) * 100)) % 100
      }

      previousLoad = load
    }
  }
}
