import Foundation

enum ProcessDictionaryKey: String {
  case pid  // e.g., "171"
  case name  // e.g., "WindowServer"
  case cpu  // e.g., "41.0"
}

@objc protocol HelperProtocol {
  func cpuUsage(with reply: @escaping (Double) -> Void)
  func processes(with reply: @escaping ([[String: String]]) -> Void)
}
