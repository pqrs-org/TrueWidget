import Combine
import Foundation

extension WidgetSource {
  public class OperatingSystem: ObservableObject {
    static let shared = OperatingSystem()

    @Published public var version: String

    private init() {
      let operatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion
      version = String(
        format: "%d.%d.%d",
        operatingSystemVersion.majorVersion,
        operatingSystemVersion.minorVersion,
        operatingSystemVersion.patchVersion
      )
    }
  }
}
