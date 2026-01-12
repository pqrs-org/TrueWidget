import Foundation
import OSLog

@MainActor
final class PrivilegedDaemonClient {
  static let shared = PrivilegedDaemonClient()

  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown",
    category: String(describing: PrivilegedDaemonClient.self))

  private var connection: NSXPCConnection?
  private var proxy: PrivilegedDaemonProtocol?

  func registerDaemon() -> Bool {
    if daemonEnabled() {
      return true
    }

    guard let result = runPrivilegedHelper(subcommand: "register") else {
      return false
    }

    if result.terminationStatus != 0 {
      if result.output.isEmpty {
        logger.error("Privileged Helper failed (register)")
      } else {
        logger.error("Privileged Helper failed (register): \(result.output, privacy: .public)")
      }
      return false
    }

    return daemonEnabled()
  }

  func unregisterDaemon() {
    if let result = runPrivilegedHelper(subcommand: "unregister"),
      result.terminationStatus != 0
    {
      if result.output.isEmpty {
        logger.error("Privileged Helper failed (unregister)")
      } else {
        logger.error("Privileged Helper failed (unregister): \(result.output, privacy: .public)")
      }
    }
    disconnect()
  }

  func daemonEnabled() -> Bool {
    guard let result = runPrivilegedHelper(subcommand: "enabled") else {
      return false
    }

    if result.terminationStatus == 0 {
      return true
    }

    if result.terminationStatus == 1 {
      return false
    }

    if !result.output.isEmpty {
      logger.error(
        "Privileged Helper enabled check failed: \(result.output, privacy: .public)"
      )
    } else {
      logger.error("Privileged Helper enabled check failed")
    }

    return false
  }

  func unmountVolume(path: String, reply: @escaping (Bool, String) -> Void) {
    Task { @MainActor in
      guard ensureRegistered() else {
        reply(false, "Privileged Helper register failed")
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
    if daemonEnabled() {
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

  private func runPrivilegedHelper(
    subcommand: String
  ) -> (terminationStatus: Int32, output: String)? {
    guard let executableURL = privilegedHelperExecutableURL() else {
      return nil
    }

    let process = Process()
    process.executableURL = executableURL
    process.arguments = [subcommand]
    process.environment = [
      "LC_ALL": "C"
    ]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
      try process.run()
      process.waitUntilExit()
    } catch {
      logger.error(
        "Unable to launch Privileged Helper (\(subcommand, privacy: .public)): \(String(describing: error), privacy: .public)"
      )
      return nil
    }

    let output =
      String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    return (process.terminationStatus, output)
  }

  private func privilegedHelperExecutableURL() -> URL? {
    let helperAppURL = Bundle.main.bundleURL.appendingPathComponent(
      "Contents/Helpers/TrueWidget Privileged Helper.app"
    )
    guard let helperBundle = Bundle(url: helperAppURL) else {
      logger.error(
        "Privileged Helper bundle not found: \(helperAppURL.path, privacy: .public)"
      )
      return nil
    }

    guard let executableURL = helperBundle.executableURL else {
      logger.error(
        "Privileged Helper executable not found: \(helperAppURL.path, privacy: .public)"
      )
      return nil
    }

    return executableURL
  }
}
