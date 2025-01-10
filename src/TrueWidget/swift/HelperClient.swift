import Foundation

@MainActor
public class HelperClient {
  static let shared = HelperClient()

  private var helperConnection: NSXPCConnection?
  private var helperProxy: HelperProtocol?

  var proxy: HelperProtocol? {
    if helperConnection == nil {
      helperConnection = NSXPCConnection(serviceName: helperServiceName)
      helperConnection?.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
      helperConnection?.resume()
    }

    if helperProxy == nil {
      helperProxy = helperConnection?.remoteObjectProxy as? HelperProtocol
    }

    return helperProxy
  }
}
