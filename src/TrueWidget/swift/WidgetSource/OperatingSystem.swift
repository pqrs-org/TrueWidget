import Combine
import Foundation

extension WidgetSource {
  public class OperatingSystem: ObservableObject {
    static let shared = OperatingSystem()

    @Published public var version: String
    @Published public var hostName: String

    private init() {
      let operatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion
      version = String(
        format: "%d.%d.%d",
        operatingSystemVersion.majorVersion,
        operatingSystemVersion.minorVersion,
        operatingSystemVersion.patchVersion
      )

      let name = ProcessInfo.processInfo.hostName
      if let index = name.firstIndex(of: ".") {
        hostName = String(name[...index].dropLast())
      } else {
        hostName = name
      }
    }
  }
}
