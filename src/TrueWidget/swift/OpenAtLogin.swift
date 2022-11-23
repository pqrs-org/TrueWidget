import Foundation

struct OpenAtLogin {
  public static var enabled: Bool {
    get {
      let bundlePath = Bundle.main.bundlePath
      let url = URL(fileURLWithPath: bundlePath)
      return OpenAtLoginObjc.enabled(url)
    }
    set {
      let bundlePath = Bundle.main.bundlePath

      // Skip if the current app is not the distributed file.

      if  // from Xcode
      bundlePath.hasSuffix("/Build/Products/Debug/TrueWidget.app")
        // from Xcode
        || bundlePath.hasSuffix("/Build/Products/Release/TrueWidget.app")
        // from command line
        || bundlePath.hasSuffix("/build/Release/TrueWidget.app")
      {
        print("Skip setting OpenAtLogin.enabled for dev")
        return
      }

      let url = URL(fileURLWithPath: bundlePath)

      if newValue {
        OpenAtLoginObjc.enable(url)
      } else {
        OpenAtLoginObjc.disable(url)
      }
    }
  }
}
