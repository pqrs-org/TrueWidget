import AsyncAlgorithms
import Combine
import Foundation

extension WidgetSource {
  public class Bundle: ObservableObject {
    public struct BundleVersion: Identifiable {
      public let id = UUID()
      public let name: String
      public let version: String

      init?(_ url: URL) {
        // Once a Bundle instance is created and associated with a url (or more precisely, a path), that instance continues to be reused.
        // As a result, even if the version or other information is updated later, outdated information will still be returned.
        // Therefore, instead of using Bundle, retrieve the information directly from Info.plist.
        let plistPath = "\(url.path)/Contents/Info.plist"
        guard let plistData = FileManager.default.contents(atPath: plistPath),
          let plistDict = try? PropertyListSerialization.propertyList(
            from: plistData, options: [], format: nil) as? [String: Any],
          let name = plistDict["CFBundleDisplayName"] as? String
            ?? plistDict["CFBundleName"] as? String,
          let version = plistDict["CFBundleShortVersionString"] as? String
        else {
          return nil
        }

        self.name = name
        self.version = version
      }
    }

    private var userSettings: UserSettings

    @Published public var bundleVersions: [String: BundleVersion] = [:]
    let timer: AsyncTimerSequence<ContinuousClock>
    var timerTask: Task<Void, Never>?

    init(userSettings: UserSettings) {
      self.userSettings = userSettings

      timer = AsyncTimerSequence(
        interval: .seconds(1),
        clock: .continuous
      )

      timerTask = Task { @MainActor in
        for await _ in timer {
          var versions: [String: BundleVersion] = [:]

          userSettings.bundleSettings.forEach { setting in
            if setting.show {
              guard
                let url = setting.url,
                let bundleVersion = BundleVersion(url)
              else { return }

              versions[url.path] = bundleVersion
            }
          }

          bundleVersions = versions

          try? await Task.sleep(for: .seconds(3.0))
        }
      }
    }
  }
}
