import Foundation

@objc protocol DeprecatedOpenAtLoginHelperProtocol {
  func registered(appURL: URL, with reply: @escaping (Bool) -> Void)
  func update(appURL: URL, register: Bool, with reply: @escaping () -> Void)
}
