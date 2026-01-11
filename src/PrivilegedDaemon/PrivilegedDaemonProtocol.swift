import Foundation

let privilegedDaemonMachServiceName = "org.pqrs.TrueWidget.PrivilegedDaemon"

@objc
protocol PrivilegedDaemonProtocol {
  func unmountVolume(path: String, reply: @escaping (Bool, String) -> Void)
}
