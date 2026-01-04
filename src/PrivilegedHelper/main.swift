import DiskArbitration
import Foundation
import OSLog

class PrivilegedHelperService: NSObject, NSXPCListenerDelegate, PrivilegedHelperProtocol {
  private let logger = Logger(
    subsystem: "org.pqrs.TrueWidget.PrivilegedHelper",
    category: String(describing: PrivilegedHelperService.self))

  private let listener = NSXPCListener(machServiceName: privilegedHelperMachServiceName)
  private let daSession: DASession?

  override init() {
    daSession = DASessionCreate(kCFAllocatorDefault)
    super.init()
    listener.delegate = self
    if let daSession {
      DASessionSetDispatchQueue(daSession, DispatchQueue.main)
    }
  }

  func run() {
    listener.resume()
  }

  func listener(
    _ listener: NSXPCListener,
    shouldAcceptNewConnection newConnection: NSXPCConnection
  ) -> Bool {
    newConnection.exportedInterface = NSXPCInterface(with: PrivilegedHelperProtocol.self)
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

    DADiskUnmount(
      disk,
      DADiskUnmountOptions(kDADiskUnmountOptionDefault),
      PrivilegedHelperService.unmountCallback,
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
}

let service = PrivilegedHelperService()
service.run()

RunLoop.current.run()
