import AsyncAlgorithms
import Combine
import Foundation

extension WidgetSource {
  public class Xcode: ObservableObject {
    public enum PathState {
      case notInstalled
      case defaultPath
      case nonDefaultPath
    }

    @Published public var path = ""
    @Published public var pathState = PathState.notInstalled

    let timer: AsyncTimerSequence<ContinuousClock>
    var timerTask: Task<Void, Never>?

    init() {
      timer = AsyncTimerSequence(
        interval: .seconds(3),
        clock: .continuous
      )

      timerTask = Task { @MainActor in
        for await _ in timer {
          let (bundlePath, pathState) = self.xcodePath()

          if self.path != bundlePath {
            self.path = bundlePath
          }

          if self.pathState != pathState {
            self.pathState = pathState
          }
        }
      }
    }

    // Since timerTask strongly references self, make sure to call cancelTimer when Xcode is no longer used.
    func cancelTimer() {
      timerTask?.cancel()
    }

    private func xcodePath() -> (String, PathState) {
      let command = "/usr/bin/xcode-select"

      if FileManager.default.fileExists(atPath: command) {
        let xcodeSelectCommand = Process()
        xcodeSelectCommand.launchPath = command
        xcodeSelectCommand.arguments = [
          "--print-path"
        ]

        xcodeSelectCommand.environment = [
          "LC_ALL": "C"
        ]

        let pipe = Pipe()
        xcodeSelectCommand.standardOutput = pipe

        xcodeSelectCommand.launch()
        xcodeSelectCommand.waitUntilExit()

        if let data = try? pipe.fileHandleForReading.readToEnd(),
          let fullPath = String(data: data, encoding: .utf8)
        {
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
      }

      return ("Xcode is not installed", .notInstalled)
    }
  }
}
