import Foundation
import SwiftShell

class Helper: NSObject, HelperProtocol {
  private let topCommand = TopCommand.shared

  @objc func cpuUsage(with reply: @escaping (Double) -> Void) {
    Task {
      reply(await topCommand.cpuUsage)
    }
  }

  @objc func processes(with reply: @escaping ([[String: String]]) -> Void) {
    Task {
      reply(await topCommand.processes)
    }
  }
}
