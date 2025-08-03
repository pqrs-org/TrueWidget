import Foundation

let helperServiceName = "org.pqrs.TrueWidget.Helper"

@objc
protocol HelperProtocol {
  //
  // AppleAccount
  //

  func appleAccount(reply: @escaping (String) -> Void)

  //
  // BundleVersions
  //

  func bundleVersions(paths: [String], reply: @escaping ([String: [String: String]]) -> Void)

  //
  // TopCommand
  //

  func topCommand(reply: @escaping @Sendable (Double, [[String: String]]) -> Void)
  func stopTopCommand()
}
