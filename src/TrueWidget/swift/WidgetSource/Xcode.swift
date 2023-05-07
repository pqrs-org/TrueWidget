import Combine
import Foundation
import SwiftShell

extension WidgetSource {
  public class Xcode: ObservableObject {
    static let shared = Xcode()

    public enum PathState {
      case notInstalled
      case defaultPath
      case nonDefaultPath
    }

    @Published public var path = ""
    @Published public var pathState = PathState.notInstalled

    private var timer: Timer?

    private init() {
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
      if !UserSettings.shared.showXcode {
        return
      }

      Task { @MainActor in
        let (bundlePath, pathState) = self.xcodePath()

        if self.path != bundlePath {
          self.path = bundlePath
        }

        if self.pathState != pathState {
          self.pathState = pathState
        }
      }
    }

    private func xcodePath() -> (String, PathState) {
      let command = "/usr/bin/xcode-select"

      if FileManager.default.fileExists(atPath: command) {
        let fullPath = run(command, "--print-path").stdout
        if fullPath.count > 0 {
          var bundlePath = ""

          if let range = fullPath.range(of: ".app/") {
            let startIndex = fullPath.startIndex
            let endIndex = fullPath.index(before: range.upperBound)
            bundlePath = String(fullPath[startIndex..<endIndex])
          } else {
            bundlePath = fullPath
          }

          if bundlePath == "/Applications/Xcode.app" {
            return (bundlePath, .defaultPath)
          } else {
            return (bundlePath, .nonDefaultPath)
          }
        }
      }

      return ("Xcode is not installed", .notInstalled)
    }
  }
}
