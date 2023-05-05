import Foundation
import ServiceManagement

// For macOS 12 or prior
final class DeprecatedOpenAtLogin {
  private static let serviceName = "org.pqrs.TrueWidget.DeprecatedOpenAtLoginHelper"
  private static let dispatchQueue: DispatchQueue = DispatchQueue(
    label: serviceName, qos: .background)
  private static let lock = NSLock()

  static func updateRegistered() {
    runHelper { proxy in
      proxy.registered(appURL: Bundle.main.bundleURL) { registered in
        OpenAtLogin.shared.registered = registered

        lock.unlock()
      }
    }
  }

  static func update(register: Bool) {
    runHelper { proxy in
      proxy.update(appURL: Bundle.main.bundleURL, register: register) {
        OpenAtLogin.shared.registered = register

        lock.unlock()
      }
    }
  }

  private static func runHelper(
    _ callback: @escaping (DeprecatedOpenAtLoginHelperProtocol) -> Void
  ) {
    dispatchQueue.async {
      let connection = NSXPCConnection(serviceName: serviceName)
      connection.remoteObjectInterface = NSXPCInterface(
        with: DeprecatedOpenAtLoginHelperProtocol.self)
      connection.resume()

      if let proxy = connection.remoteObjectProxy as? DeprecatedOpenAtLoginHelperProtocol {
        do {
          lock.lock()  // Unlocked at the end of callback

          callback(proxy)
        }

        do {
          lock.lock()  // Wait until callback is called.
          defer { lock.unlock() }

          connection.invalidate()
        }
      }
    }
  }
}
