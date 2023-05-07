import Foundation

@objc protocol OpenAtLoginHelperProtocol {
  func registered(appURL: URL, with reply: @escaping (Bool) -> Void)
  func update(appURL: URL, register: Bool, with reply: @escaping () -> Void)
}
