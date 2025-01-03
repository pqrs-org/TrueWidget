import Combine
import Foundation

extension WidgetSource {
  public class OperatingSystem: ObservableObject {
    private var userSettings: UserSettings

    @Published public var version = ""
    @Published public var hostName = ""
    @Published public var rootVolumeName = ""
    @Published public var userName = ""

    private var timer: Timer?

    init(userSettings: UserSettings) {
      self.userSettings = userSettings

      // We have to use `operatingSystemVersionString` instead of `operatingSystemVersion` because
      // `operatingSystemVersion` does not have a security update version, such as "(a)" in "13.3.1 (a)".
      //
      // Note: operatingSystemVersionString returns "Version 13.3.1 (a) (Build 22E772610a)"
      version = ProcessInfo.processInfo.operatingSystemVersionString.replacingOccurrences(
        of: "Version ", with: "")
      if let index = version.range(of: "(Build ")?.lowerBound {
        version = String(version[..<index])
      }

      rootVolumeName = volumeName("/")

      userName = NSUserName()

      timer = Timer.scheduledTimer(
        withTimeInterval: 3.0,
        repeats: true
      ) { [weak self] (_: Timer) in
        guard let self = self else { return }

        self.update()
      }

      self.update()
    }

    private func volumeName(_ path: String) -> String {
      let rootURL = NSURL.fileURL(withPath: "/", isDirectory: true)
      if let resourceValues = try? rootURL.resourceValues(forKeys: [.volumeNameKey]) {
        return resourceValues.volumeName ?? ""
      }

      return ""
    }

    private func update() {
      if !userSettings.showHostName {
        return
      }

      // `ProcessInfo.processInfo.hostName` is not reflected the host name changes after the application is launched.
      // So, we have to use `gethostname`.`
      let length = 128
      var buffer = [CChar](repeating: 0, count: length)
      let error = gethostname(&buffer, length)
      if error == 0 {
        if let name = String(utf8String: buffer) {
          var h = name
          if let index = name.firstIndex(of: ".") {
            h = String(name[...index].dropLast())
          }

          if hostName != h {
            hostName = h
          }
        }
      }
    }
  }
}
