import DiskArbitration
import Foundation
import OSLog
import Security

let logger = Logger(
  subsystem: "org.pqrs.TrueWidget.PrivilegedDaemon",
  category: String(describing: "main"))

class PrivilegedDaemonService: NSObject, NSXPCListenerDelegate, PrivilegedDaemonProtocol {
  private let listener = NSXPCListener(machServiceName: privilegedDaemonMachServiceName)
  private let daSession: DASession?
  private let expectedTeamID = PrivilegedDaemonService.loadTeamID()
  private let expectedBundleID = "org.pqrs.TrueWidget"

  override init() {
    daSession = DASessionCreate(kCFAllocatorDefault)
    super.init()
    listener.delegate = self
    if let daSession {
      DASessionSetDispatchQueue(daSession, DispatchQueue.main)
    }
  }

  func run() {
    logger.info("expectedTeamID: \(self.expectedTeamID ?? "empty", privacy: .public)")
    logger.info("expectedBundleID: \(self.expectedBundleID, privacy: .public)")

    listener.resume()
  }

  func listener(
    _ listener: NSXPCListener,
    shouldAcceptNewConnection newConnection: NSXPCConnection
  ) -> Bool {
    guard validate(connection: newConnection) else {
      return false
    }

    newConnection.exportedInterface = NSXPCInterface(with: PrivilegedDaemonProtocol.self)
    newConnection.exportedObject = self
    newConnection.resume()
    return true
  }

  @objc func unmountVolume(path: String, reply: @escaping (Bool, String) -> Void) {
    logger.info("unmountVolume path:\(path, privacy: .public)")

    guard let daSession else {
      reply(false, "DASessionCreate failed")
      return
    }

    let url = URL(fileURLWithPath: path)
    guard let disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, daSession, url as CFURL) else {
      reply(false, "DADiskCreateFromVolumePath failed")
      return
    }

    let context = UnmountContext(reply: reply)
    let unmanaged = Unmanaged.passRetained(context)

    // An issues occur where macOS 13 Data volumes cannot be unmounted on macOS 26.
    // So we specify kDADiskUnmountOptionForce as the option.
    DADiskUnmount(
      disk,
      DADiskUnmountOptions(kDADiskUnmountOptionForce),
      PrivilegedDaemonService.unmountCallback,
      unmanaged.toOpaque()
    )
  }

  private final class UnmountContext {
    let reply: (Bool, String) -> Void

    init(reply: @escaping (Bool, String) -> Void) {
      self.reply = reply
    }
  }

  private static let unmountCallback: DADiskUnmountCallback = { _, dissenter, context in
    guard let context else {
      return
    }

    let unmountContext = Unmanaged<UnmountContext>.fromOpaque(context).takeRetainedValue()

    if let dissenter {
      let status = DADissenterGetStatus(dissenter)
      let statusString = DADissenterGetStatusString(dissenter) as String? ?? "unknown"
      unmountContext.reply(false, "status:\(status) reason:\(statusString)")
    } else {
      unmountContext.reply(true, "")
    }
  }

  private func validate(connection: NSXPCConnection) -> Bool {
    guard let expectedTeamID else {
      logger.error("Expected Team ID is unavailable")
      return false
    }

    let pid = connection.processIdentifier
    guard let guestStaticCode = Self.staticCodeForProcess(pid: pid) else {
      logger.error("SecCodeCopyGuestWithAttributes failed for pid:\(pid)")
      return false
    }

    let requirementString =
      "anchor apple generic"
      + " and certificate leaf[subject.OU] = \"\(expectedTeamID)\""
      + " and identifier \"\(expectedBundleID)\""
    var requirement: SecRequirement?
    let requirementStatus = SecRequirementCreateWithString(
      requirementString as CFString,
      SecCSFlags(),
      &requirement
    )
    guard requirementStatus == errSecSuccess, let requirement else {
      logger.error("SecRequirementCreateWithString failed: \(requirementStatus, privacy: .public)")
      return false
    }

    let validityStatus = SecStaticCodeCheckValidity(
      guestStaticCode,
      SecCSFlags(),
      requirement
    )
    guard validityStatus == errSecSuccess else {
      logger.error("SecStaticCodeCheckValidity failed: \(validityStatus, privacy: .public)")
      return false
    }

    return true
  }

  private static func loadTeamID() -> String? {
    guard let staticCode = staticCodeForSelf() else {
      return nil
    }

    if !verifyCode(code: staticCode, requirementString: "anchor apple generic") {
      return nil
    }

    guard let signingInfo = signingInfo(for: staticCode) else {
      return nil
    }

    return signingInfo[kSecCodeInfoTeamIdentifier as String] as? String
  }

  private static func staticCodeForSelf() -> SecStaticCode? {
    var code: SecCode?
    let status = SecCodeCopySelf(SecCSFlags(), &code)
    guard status == errSecSuccess, let code else {
      logger.error("SecCodeCopySelf failed: \(status, privacy: .public)")
      return nil
    }

    return staticCode(from: code)
  }

  private static func staticCodeForProcess(pid: pid_t) -> SecStaticCode? {
    let attributes = [kSecGuestAttributePid: NSNumber(value: pid)] as CFDictionary

    var code: SecCode?
    let status = SecCodeCopyGuestWithAttributes(nil, attributes, SecCSFlags(), &code)
    guard status == errSecSuccess, let code else {
      logger.error("SecCodeCopyGuestWithAttributes failed: \(status, privacy: .public)")
      return nil
    }

    return staticCode(from: code)
  }

  private static func staticCode(from code: SecCode) -> SecStaticCode? {
    var staticCode: SecStaticCode?
    let status = SecCodeCopyStaticCode(code, SecCSFlags(), &staticCode)
    guard status == errSecSuccess, let staticCode else {
      logger.error("SecCodeCopyStaticCode failed: \(status, privacy: .public)")
      return nil
    }

    return staticCode
  }

  private static func verifyCode(code: SecStaticCode, requirementString: String) -> Bool {
    var requirement: SecRequirement?
    let requirementStatus = SecRequirementCreateWithString(
      requirementString as CFString, SecCSFlags(), &requirement)
    guard requirementStatus == errSecSuccess, let requirement else {
      logger.error("SecRequirementCreateWithString failed: \(requirementStatus, privacy: .public)")
      return false
    }

    let validityStatus = SecStaticCodeCheckValidity(code, SecCSFlags(), requirement)
    guard validityStatus == errSecSuccess else {
      logger.error("SecStaticCodeCheckValidity failed: \(validityStatus, privacy: .public)")
      return false
    }

    return true
  }

  private static func signingInfo(for staticCode: SecStaticCode) -> [String: Any]? {
    var signingInfo: CFDictionary?
    let status = SecCodeCopySigningInformation(
      staticCode,
      SecCSFlags(rawValue: kSecCSSigningInformation),
      &signingInfo)
    guard status == errSecSuccess, let info = signingInfo as? [String: Any] else {
      logger.error("SecCodeCopySigningInformation failed: \(status, privacy: .public)")
      return nil
    }

    return info
  }
}

let service = PrivilegedDaemonService()
service.run()

RunLoop.current.run()
