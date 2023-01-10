import Foundation
import SwiftShell

class Helper: NSObject, HelperProtocol {
  private let topCommandDispatchQueue: DispatchQueue

  // CPU usage: 10.84% user, 8.27% sys, 80.88% idle
  private let topCPUUsageRegex: NSRegularExpression
  // PID    %CPU COMMAND
  private let topProcessesStartRegex: NSRegularExpression
  // 75529  21.5 Google Chrome He
  private let topProcessRegex: NSRegularExpression
  // Processes: 652 total, 5 running, 647 sleeping, 3732 threads
  private let topProcessesEndRegex: NSRegularExpression

  private let topLock = NSLock()
  private var topCPUUsage = 0.0
  private var topProcesses = [[String: String]]()

  override init() {
    topCommandDispatchQueue = DispatchQueue(
      label: "org.pqrs.truewidget.helper.top", qos: .background)

    topCPUUsageRegex = try! NSRegularExpression(
      pattern: "^CPU usage: ([\\d\\.]+)% user, ([\\d\\.]+)% sys, ")

    topProcessesStartRegex = try! NSRegularExpression(pattern: "^PID\\s+%CPU\\s+COMMAND")

    topProcessRegex = try! NSRegularExpression(pattern: "^(\\d+)\\s+([\\d\\.]+)\\s+(.+)")

    topProcessesEndRegex = try! NSRegularExpression(pattern: "^Processes:")

    super.init()

    topCommandDispatchQueue.async { [weak self] in
      guard let self = self else { return }

      var context = CustomContext(main)
      context.env["LC_ALL"] = "C"

      let command = context.runAsync(
        "/usr/bin/top",
        "-stats", "pid,cpu,command",
        "-l", "0",
        "-n", "3",
        "-s", "3"
      )

      var inProcessesLine = false
      var newProcesses = [[String: String]]()

      command.stdout.onOutput { [weak self] stdout in
        guard let self = self else { return }

        for line in stdout.lines() {
          //
          // Parse CPU usage
          //

          let cpuUsage = line.capturedGroups(withRegex: self.topCPUUsageRegex)
          if cpuUsage.count > 0 {
            self.topLock.lock()
            defer { self.topLock.unlock() }

            self.topCPUUsage = Double(cpuUsage[0])! + Double(cpuUsage[1])!
          }

          //
          // Parse processes
          //

          if inProcessesLine {
            if self.topProcessesEndRegex.numberOfMatches(
              in: line, range: NSRange(line.startIndex..., in: line)) > 0
            {
              inProcessesLine = false

              self.topLock.lock()
              defer { self.topLock.unlock() }

              self.topProcesses = newProcesses
            }

            let process = line.capturedGroups(withRegex: self.topProcessRegex)
            if process.count > 0 {
              newProcesses.append(
                [
                  ProcessDictionaryKey.pid.rawValue: process[0],
                  ProcessDictionaryKey.name.rawValue: process[2].trimmingCharacters(
                    in: .whitespacesAndNewlines),
                  ProcessDictionaryKey.cpu.rawValue: process[1],
                ])
            }
          }

          if self.topProcessesStartRegex.numberOfMatches(
            in: line, range: NSRange(line.startIndex..., in: line)) > 0
          {
            inProcessesLine = true
            newProcesses.removeAll()
          }
        }
      }

      do {
        try command.finish()
      } catch {
        print(error)
      }
    }
  }

  @objc func cpuUsage(with reply: @escaping (Double) -> Void) {
    topLock.lock()
    defer { topLock.unlock() }

    reply(topCPUUsage)
  }

  @objc func processes(with reply: @escaping ([[String: String]]) -> Void) {
    topLock.lock()
    defer { topLock.unlock() }

    reply(topProcesses)
  }
}
