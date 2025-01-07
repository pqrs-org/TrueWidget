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
        guard
          let bundle = Foundation.Bundle(url: url),
          let name = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String,
          let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
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
