import Foundation
import OSLog
import ServiceManagement

@MainActor
final class PrivilegedDaemonClient {
  static let shared = PrivilegedDaemonClient()
  private static let serviceName = "org.pqrs.TrueWidget.PrivilegedDaemon"

  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown",
    category: String(describing: PrivilegedDaemonClient.self))

  private let daemonService = SMAppService.daemon(plistName: serviceName + ".plist")
  private var connection: NSXPCConnection?
  private var proxy: PrivilegedDaemonProtocol?

  func registerDaemon() -> Bool {
    do {
      // Regarding daemons, performing the following steps causes inconsistencies in the user approval database,
      // so the process will not start again until it is unregistered and then registered again.
      //
      // 1. Register a daemon.
      // 2. Approve the daemon.
      // 3. The database is reset using `sfltool resetbtm`.
      // 4. Restart macOS.
      //
      // When this happens, the service status becomes .notFound.
      // So, if the service status is .notFound, we call unregister before register to avoid this issue.
      //
      // Another case where it becomes .notFound is when it has never actually been registered before.
      // Even in this case, calling unregister will not have any negative impact.

      if daemonService.status == .notFound {
        unregisterDaemon()
      }

      try daemonService.register()
    } catch {
      logger.error("SMAppService register failed: \(String(describing: error), privacy: .public)")
      return false
    }

    return daemonService.status == .enabled
  }

  func unregisterDaemon() {
    do {
      try daemonService.unregister()
    } catch {
      logger.error("SMAppService unregister failed: \(String(describing: error), privacy: .public)")
    }

    disconnect()
  }

  func daemonStatus() -> SMAppService.Status {
    return daemonService.status
  }

  func unmountVolume(path: String, reply: @escaping (Bool, String) -> Void) {
    Task { @MainActor in
      guard ensureRegistered() else {
        reply(false, "SMAppService register failed")
        return
      }

      guard let proxy = ensureConnected() else {
        reply(false, "Privileged Daemon unavailable")
        return
      }

      proxy.unmountVolume(path: path, reply: reply)
    }
  }

  private func ensureRegistered() -> Bool {
    if daemonService.status == .enabled {
      return true
    }

    return registerDaemon()
  }

  private func ensureConnected() -> PrivilegedDaemonProtocol? {
    if connection == nil {
      connection = NSXPCConnection(
        machServiceName: privilegedDaemonMachServiceName,
        options: .privileged
      )
      connection?.remoteObjectInterface = NSXPCInterface(with: PrivilegedDaemonProtocol.self)
      connection?.resume()
    }

    if proxy == nil {
      proxy = connection?.remoteObjectProxy as? PrivilegedDaemonProtocol
    }

    return proxy
  }

  private func disconnect() {
    connection?.invalidate()
    connection = nil
    proxy = nil
  }
}
