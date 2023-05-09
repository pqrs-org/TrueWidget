import Foundation

extension Helper {
  @objc func topCommandCPUUsage(with reply: @escaping (Double) -> Void) {
    Task {
      reply(await TopCommand.shared.cpuUsage)
    }
  }

  @objc func topCommandProcesses(with reply: @escaping ([[String: String]]) -> Void) {
    Task {
      reply(await TopCommand.shared.processes)
    }
  }
}
