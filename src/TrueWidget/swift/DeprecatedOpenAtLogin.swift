import Foundation
import ServiceManagement

// For macOS 12 or prior
final class DeprecatedOpenAtLogin {
  private static let serviceName = "org.pqrs.TrueWidget.DeprecatedOpenAtLoginHelper"

  static func updateRegistered() {
    runHelper { proxy in
      proxy.registered(appURL: Bundle.main.bundleURL) { registered in
        OpenAtLogin.shared.registered = registered

        NotificationCenter.default.post(
          name: OpenAtLogin.registeredChanged,
          object: nil)
      }
    }
  }

  static func update(register: Bool) {
    runHelper { proxy in
      proxy.update(appURL: Bundle.main.bundleURL, register: register) {
        OpenAtLogin.shared.registered = register
      }
    }
  }

  private static func runHelper(
    _ callback: @escaping (DeprecatedOpenAtLoginHelperProtocol) -> Void
  ) {
    Task.detached {
      let connection = NSXPCConnection(serviceName: serviceName)
      connection.remoteObjectInterface = NSXPCInterface(
        with: DeprecatedOpenAtLoginHelperProtocol.self)
      connection.resume()

      if let proxy = connection.synchronousRemoteObjectProxyWithErrorHandler({ error in
        OpenAtLogin.shared.error = error.localizedDescription
      }) as? DeprecatedOpenAtLoginHelperProtocol {
        callback(proxy)
        connection.invalidate()
      }
    }
  }
}
