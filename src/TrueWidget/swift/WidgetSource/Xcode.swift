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

      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }

        let command = "/usr/bin/xcode-select"
        if FileManager.default.fileExists(atPath: command) {
          let fullPath = run(command, "--print-path").stdout
          if fullPath.count > 0 {
            if let range = fullPath.range(of: ".app/") {
              let startIndex = fullPath.startIndex
              let endIndex = fullPath.index(before: range.upperBound)
              self.path = String(fullPath[startIndex..<endIndex])
            } else {
              self.path = fullPath
            }

            if self.path == "/Applications/Xcode.app" {
              self.pathState = .defaultPath
            } else {
              self.pathState = .nonDefaultPath
            }

            return
          }
        }

        self.path = "Xcode is not installed"
        self.pathState = .notInstalled
      }
    }
  }
}
