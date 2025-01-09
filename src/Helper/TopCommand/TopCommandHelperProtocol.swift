import Foundation

enum ProcessDictionaryKey: String {
  case name  // e.g., "WindowServer"
  case cpu  // e.g., "41.0"
}

let topCommandProcessesInitialValue: [[String: String]] = [[:], [:], [:]]

@objc protocol TopCommandHelperProtocol {
  func topCommandCPUUsage(with reply: @escaping (Double) -> Void)
  func topCommandProcesses(with reply: @escaping ([[String: String]]) -> Void)
}
