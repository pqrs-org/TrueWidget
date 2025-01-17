import Foundation

class HelperService: NSObject, NSXPCListenerDelegate, HelperProtocol {
  let listener = NSXPCListener.service()

  override init() {
    super.init()
    listener.delegate = self
  }

  func startListening() {
    listener.resume()
  }

  func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection)
    -> Bool
  {
    newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
    newConnection.exportedObject = self
    newConnection.resume()
    return true
  }

  //
  // AppleAccount
  //

  func appleAccount(reply: @escaping (String) -> Void) {
    let account =
      (UserDefaults.standard.persistentDomain(forName: "MobileMeAccounts")?["Accounts"]
      as? [[String: Any]])?.first?["AccountID"] as? String ?? ""
    reply(account)
  }

  //
  // BundleVersions
  //

  @objc func bundleVersions(
    paths: [String], reply: @escaping ([String: [String: String]]) -> Void
  ) {
    var versions: [String: [String: String]] = [:]

    for path in paths {
      // Once a Bundle instance is created and associated with a url (or more precisely, a path), that instance continues to be reused.
      // As a result, even if the version or other information is updated later, outdated information will still be returned.
      // Therefore, instead of using Bundle, retrieve the information directly from Info.plist.
      let url = URL(fileURLWithPath: path)
      let plistPath =
        url
        .appending(component: "Contents", directoryHint: .isDirectory)
        .appending(component: "Info.plist", directoryHint: .notDirectory)
        .path

      guard let plistData = FileManager.default.contents(atPath: plistPath),
        let plistDict = try? PropertyListSerialization.propertyList(
          from: plistData, options: [], format: nil) as? [String: Any],
        let version = plistDict["CFBundleShortVersionString"] as? String
          ?? plistDict["CFBundleVersion"] as? String
      else {
        continue
      }

      versions[path] = [
        "name": plistDict["CFBundleDisplayName"] as? String
          ?? plistDict["CFBundleName"] as? String
          ?? url.lastPathComponent,
        "version": version,
      ]
    }

    reply(versions)
  }

  //
  // TopCommand
  //

  private var topCommandTask: Task<Void, Never>?
  private var topCommandData: TopCommandData = TopCommandData()

  @objc func topCommand(reply: @escaping (Double, [[String: String]]) -> Void) {
    if topCommandTask == nil {
      topCommandTask = Task {
        do {
          for try await data in topCommandStream() {
            Task { @MainActor in
              topCommandData = data
            }
          }
        } catch {
          print("error in topCommandStream: \(error)")
          stopTopCommand()
        }
      }
    }

    Task { @MainActor in
      reply(topCommandData.cpuUsage, topCommandData.processes)
    }
  }

  @objc func stopTopCommand() {
    topCommandTask?.cancel()
    topCommandTask = nil
    topCommandData = TopCommandData()
  }
}

let service = HelperService()
service.startListening()
