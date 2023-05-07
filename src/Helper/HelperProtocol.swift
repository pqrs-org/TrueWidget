import Foundation

enum ProcessDictionaryKey: String {
  case pid  // e.g., "171"
  case name  // e.g., "WindowServer"
  case cpu  // e.g., "41.0"
}

let HelperProcessesInitialValue: [[String: String]] = [
  [
    ProcessDictionaryKey.pid.rawValue: "-1",
    ProcessDictionaryKey.name.rawValue: "---",
    ProcessDictionaryKey.cpu.rawValue: "0.0",
  ],
  [
    ProcessDictionaryKey.pid.rawValue: "-2",
    ProcessDictionaryKey.name.rawValue: "---",
    ProcessDictionaryKey.cpu.rawValue: "0.0",
  ],
  [
    ProcessDictionaryKey.pid.rawValue: "-3",
    ProcessDictionaryKey.name.rawValue: "---",
    ProcessDictionaryKey.cpu.rawValue: "0.0",
  ],
]

@objc protocol HelperProtocol {
  func cpuUsage(with reply: @escaping (Double) -> Void)
  func processes(with reply: @escaping ([[String: String]]) -> Void)
}
