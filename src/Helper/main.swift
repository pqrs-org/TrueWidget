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

  @objc func topCommand(reply: @escaping @Sendable (Double, [[String: String]]) -> Void) {
    Task { @MainActor in
      let snapshot = TopCommandHandler.shared.snapshot()
      reply(snapshot.cpuUsage, snapshot.processes)
    }
  }

  @objc func stopTopCommand() {
    Task { @MainActor in
      TopCommandHandler.shared.stop()
    }
  }

  //
  // Diskutil
  //

  @objc func apfsListPlist(reply: @escaping (Data?, String) -> Void) {
    let command = "/usr/sbin/diskutil"
    guard FileManager.default.fileExists(atPath: command) else {
      reply(nil, "diskutil not found")
      return
    }

    let process = Process()
    process.launchPath = command
    process.arguments = [
      "apfs",
      "list",
      "-plist",
    ]
    process.environment = [
      "LANG": "C",
      "LC_ALL": "C",
    ]

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    do {
      try process.run()
      process.waitUntilExit()
    } catch {
      reply(nil, "diskutil failed to run")
      return
    }

    let errorData = (try? errorPipe.fileHandleForReading.readToEnd()) ?? Data()
    let errorMessage = String(data: errorData, encoding: .utf8) ?? ""

    guard process.terminationStatus == 0 else {
      reply(nil, errorMessage)
      return
    }

    let data = (try? outputPipe.fileHandleForReading.readToEnd()) ?? Data()
    if data.isEmpty {
      reply(nil, "diskutil returned empty plist")
      return
    }

    reply(data, errorMessage)
  }
}

let service = HelperService()
service.startListening()
