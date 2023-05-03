import Foundation
import ServiceManagement

final class OpenAtLogin: ObservableObject {
  static let shared = OpenAtLogin()
  var error = ""

  func registerLauncher(enabled: Bool) {
    let launcherBundleIdentifier = "org.pqrs.TrueWidget.Launcher"

    error = ""

    if #available(macOS 13.0, *) {
      //
      // Unregister a helper that was registered on macOS 12 or earlier.
      //

      let service = SMAppService.loginItem(identifier: launcherBundleIdentifier)
      try? service.unregister()

      //
      // Register mainApp
      //

      do {
        if enabled {
          try SMAppService.mainApp.register()
        } else {
          try SMAppService.mainApp.unregister()
        }
      } catch {
        self.error = error.localizedDescription
      }
    } else {
      let result = SMLoginItemSetEnabled(launcherBundleIdentifier as CFString, enabled)
      if !result {
        error = "SMLoginItemSetEnabled error"
      }
    }
  }
}
