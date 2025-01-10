import Foundation

extension Helper {
  @objc func bundleVersions(
    paths: [String], with reply: @escaping ([String: [String: String]]) -> Void
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
}
