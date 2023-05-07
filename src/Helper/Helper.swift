import Foundation
import SwiftShell

class Helper: NSObject, HelperProtocol {
  private let topCommand = TopCommand.shared

  @objc func cpuUsage(with reply: @escaping (Double) -> Void) {
    reply(topCommand.cpuUsage)
  }

  @objc func processes(with reply: @escaping ([[String: String]]) -> Void) {
    reply(topCommand.processes)
  }
}
