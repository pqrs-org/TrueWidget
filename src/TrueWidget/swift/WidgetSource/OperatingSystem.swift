import Combine
import Foundation

extension WidgetSource {
  public class OperatingSystem: ObservableObject {
    static let shared = OperatingSystem()

    @Published public var version = ""
    @Published public var hostName = ""

    private var timer: Timer?

    private init() {
      let operatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion
      version = String(
        format: "%d.%d.%d",
        operatingSystemVersion.majorVersion,
        operatingSystemVersion.minorVersion,
        operatingSystemVersion.patchVersion
      )

      timer = Timer.scheduledTimer(
        withTimeInterval: 3.0,
        repeats: true
      ) { [weak self] (_: Timer) in
        guard let self = self else { return }

        self.update()
      }

      self.update()
    }

    private func update() {
      if !UserSettings.shared.showHostName {
        return
      }

      // `ProcessInfo.processInfo.hostName` is not reflected the host name changes after the application is launched.
      // So, we have to use `gethostname`.`
      let length = 128
      var buffer = [CChar](repeating: 0, count: length)
      let error = gethostname(&buffer, length)
      if error == 0 {
        if let name = String(utf8String: buffer) {
          if let index = name.firstIndex(of: ".") {
            hostName = String(name[...index].dropLast())
          } else {
            hostName = name
          }
        }
      }
    }
  }
}
