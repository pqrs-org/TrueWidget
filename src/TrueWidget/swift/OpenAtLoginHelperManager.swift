import Foundation
import ServiceManagement

// For macOS 12 or prior
actor OpenAtLoginHelperManager {
  static let shared = OpenAtLoginHelperManager()

  private let serviceName = "org.pqrs.TrueWidget.OpenAtLoginHelper"

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
    _ callback: @escaping (OpenAtLoginHelperProtocol) -> Void
  ) {
    let connection = NSXPCConnection(serviceName: self.serviceName)
    connection.remoteObjectInterface = NSXPCInterface(
      with: OpenAtLoginHelperProtocol.self)
    connection.resume()

    if let proxy = connection.synchronousRemoteObjectProxyWithErrorHandler({ error in
      OpenAtLogin.shared.error = error.localizedDescription
    }) as? OpenAtLoginHelperProtocol {
      callback(proxy)
    }

    connection.invalidate()
  }
}
