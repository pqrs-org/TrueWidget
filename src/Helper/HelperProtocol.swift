import Foundation

let helperServiceName = "org.pqrs.TrueWidget.Helper"

@objc
protocol HelperProtocol:
  DeprecatedOpenAtLoginHelperProtocol,
  TopCommandHelperProtocol
{}
