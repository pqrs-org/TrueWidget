import Foundation

let privilegedDaemonMachServiceName = "org.pqrs.TrueWidget.PrivilegedDaemon"

@objc
protocol PrivilegedDaemonProtocol {
  // Compare the app and daemon versions, and if they don't match, terminate the daemon.
  func checkVersion(appBundleVersion: String, reply: @escaping (Bool, String) -> Void)
  func unmountVolume(path: String, reply: @escaping (Bool, String) -> Void)
}
