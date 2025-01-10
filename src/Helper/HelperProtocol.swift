import Foundation

let helperServiceName = "org.pqrs.TrueWidget.Helper"

@objc
protocol HelperProtocol {
  //
  // BundleVersions
  //

  func bundleVersions(paths: [String], with reply: @escaping ([[String: String]]) -> Void)

  //
  // TopCommand
  //

  func topCommandCPUUsage(with reply: @escaping (Double) -> Void)
  func topCommandProcesses(with reply: @escaping ([[String: String]]) -> Void)

}
