import Combine
import Foundation
import SwiftShell

extension WidgetSource {
  public class Xcode: ObservableObject {
    static let shared = Xcode()

    @Published public var path = ""

    private var timer: Timer?

    private init() {
      timer = Timer.scheduledTimer(
        withTimeInterval: 3.0,
        repeats: true
      ) { [weak self] (_: Timer) in
        guard let self = self else { return }

        self.update()
      }

      update()
    }

    private func update() {
      if !UserSettings.shared.showXcode {
        return
      }

      let command = "/usr/bin/xcode-select"
      if FileManager.default.fileExists(atPath: command) {
        let fullPath = run(command, "--print-path").stdout
        if fullPath.count > 0 {
          if let range = fullPath.range(of: ".app/") {
            let startIndex = fullPath.startIndex
            let endIndex = fullPath.index(before: range.upperBound)
            path = String(fullPath[startIndex..<endIndex])
          } else {
            path = fullPath
          }
          return
        }
      }

      path = "not installed"
    }
  }
}
