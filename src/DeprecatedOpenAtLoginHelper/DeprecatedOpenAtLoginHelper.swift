import CoreServices
import Foundation
import ServiceManagement

final class DeprecatedOpenAtLoginHelper: NSObject, DeprecatedOpenAtLoginHelperProtocol {
  //
  // For macOS 12 or prior.
  // There are no alternative exists on macOS 11 and macOS 12, deprecated methods have to be used.
  //
  // Note:
  // LSSharedFileListInsertItemURL and LSSharedFileListItemRemove does not work in sandbox.
  //

  @objc func registered(appURL: URL, with reply: @escaping (Bool) -> Void) {
    reply(DeprecatedOpenAtLoginHelperObjc.registered(appURL))

    exit()
  }

  @objc func update(appURL: URL, register: Bool, with reply: @escaping () -> Void) {
    if register {
      DeprecatedOpenAtLoginHelperObjc.register(appURL)
    } else {
      DeprecatedOpenAtLoginHelperObjc.unregister(appURL)
    }

    reply()

    exit()
  }

  private func exit() {
    // Wait for a while before exit for the client's NSXPCConnection invalidation.
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      Darwin.exit(0)
    }
  }
}
