import Foundation

let privilegedHelperMachServiceName = "org.pqrs.TrueWidget.PrivilegedHelper"

@objc
protocol PrivilegedHelperProtocol {
  func unmountVolume(path: String, reply: @escaping (Bool, String) -> Void)
}
