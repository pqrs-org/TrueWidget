import CoreServices
import Foundation
import ServiceManagement

final class OpenAtLoginHelper: NSObject, OpenAtLoginHelperProtocol {
  //
  // For macOS 12 or prior.
  // There are no alternative exists on macOS 11 and macOS 12, deprecated methods have to be used.
  //
  // Note:
  // LSSharedFileListInsertItemURL and LSSharedFileListItemRemove does not work in sandbox.
  //

  @objc func registered(appURL: URL, with reply: @escaping (Bool) -> Void) {
    reply(OpenAtLoginHelperObjc.registered(appURL))
  }

  @objc func update(appURL: URL, register: Bool, with reply: @escaping () -> Void) {
    if register {
      OpenAtLoginHelperObjc.register(appURL)
    } else {
      OpenAtLoginHelperObjc.unregister(appURL)
    }

    reply()
  }
}
