import Foundation

let helperServiceName = "org.pqrs.TrueWidget.Helper"

@objc
protocol HelperProtocol {
  //
  // BundleVersions
  //

  func bundleVersions(paths: [String], reply: @escaping ([String: [String: String]]) -> Void)

  //
  // TopCommand
  //

  func topCommand(reply: @escaping (Double, [[String: String]]) -> Void)
  func stopTopCommand()
}
