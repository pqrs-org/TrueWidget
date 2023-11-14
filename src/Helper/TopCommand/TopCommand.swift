import Foundation
import SwiftShell

actor TopCommand {
  static let shared = TopCommand()

  // CPU usage: 10.84% user, 8.27% sys, 80.88% idle
  private let topCPUUsageRegex: NSRegularExpression?
  // PID    %CPU COMMAND
  private let topProcessesStartRegex: NSRegularExpression?
  // 75529  21.5 Google Chrome He
  private let topProcessRegex: NSRegularExpression?
  // Processes: 652 total, 5 running, 647 sleeping, 3732 threads
  private let topProcessesEndRegex: NSRegularExpression?

  var cpuUsage = 0.0
  var processes: [[String: String]] = topCommandProcessesInitialValue

  init() {
    topCPUUsageRegex = try? NSRegularExpression(
      pattern: "^CPU usage: ([\\d\\.]+)% user, ([\\d\\.]+)% sys, ")

    topProcessesStartRegex = try? NSRegularExpression(pattern: "^PID\\s+%CPU\\s+COMMAND")

    topProcessRegex = try? NSRegularExpression(pattern: "^(\\d+)\\s+([\\d\\.]+)\\s+(.+)")

    topProcessesEndRegex = try? NSRegularExpression(pattern: "^Processes:")

    Task {
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

        guard
          let topCPUUsageRegex = self.topCPUUsageRegex,
          let topProcessesStartRegex = self.topProcessesStartRegex,
          let topProcessRegex = self.topProcessRegex,
          let topProcessesEndRegex = self.topProcessesEndRegex
        else { return }

        for line in stdout.lines() {
          //
          // Parse CPU usage
          //

          let cpuUsages = line.capturedGroups(withRegex: topCPUUsageRegex)
          if cpuUsages.count > 0 {
            Task {
              await self.update(cpuUsage: Double(cpuUsages[0])! + Double(cpuUsages[1])!)
            }
          }

          //
          // Parse processes
          //

          if inProcessesLine {
            if topProcessesEndRegex.numberOfMatches(
              in: line, range: NSRange(line.startIndex..., in: line)) > 0
            {
              inProcessesLine = false

              let copy = newProcesses
              Task {
                await self.update(processes: copy)
              }
            }

            let process = line.capturedGroups(withRegex: topProcessRegex)
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

          if topProcessesStartRegex.numberOfMatches(
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

  private func update(cpuUsage: Double) async {
    self.cpuUsage = cpuUsage
  }

  private func update(processes: [[String: String]]) async {
    self.processes = processes
  }
}
