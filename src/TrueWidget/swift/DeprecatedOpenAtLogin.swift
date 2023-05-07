import Foundation
import ServiceManagement

// For macOS 12 or prior
final class DeprecatedOpenAtLogin {
  static let shared = DeprecatedOpenAtLogin()

  private let serviceName = "org.pqrs.TrueWidget.DeprecatedOpenAtLoginHelper"

  func updateRegistered() {
    runHelper { proxy in
      proxy.registered(appURL: Bundle.main.bundleURL) { registered in
        Task { @MainActor in
          OpenAtLogin.shared.registered = registered
        }
      }
    }
  }

  func update(register: Bool) {
    runHelper { proxy in
      proxy.update(appURL: Bundle.main.bundleURL, register: register) {
        Task { @MainActor in
          OpenAtLogin.shared.registered = register
        }
      }
    }
  }

  private func runHelper(
    _ callback: @escaping (DeprecatedOpenAtLoginHelperProtocol) -> Void
  ) {
    Task.detached {
      let connection = NSXPCConnection(serviceName: self.serviceName)
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
