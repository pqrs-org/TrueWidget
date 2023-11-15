import Foundation

actor TopCommand {
  static let shared = TopCommand()

  var cpuUsage = 0.0
  var processes: [[String: String]] = topCommandProcessesInitialValue

  init() {
    Task {
      await runTopCommand()
    }
  }

  private func runTopCommand() async {
    guard
      // CPU usage: 10.84% user, 8.27% sys, 80.88% idle
      let topCPUUsageRegex = try? NSRegularExpression(
        pattern: "^CPU usage: ([\\d\\.]+)% user, ([\\d\\.]+)% sys, "),
      // PID    %CPU COMMAND
      let topProcessesStartRegex = try? NSRegularExpression(pattern: "^PID\\s+%CPU\\s+COMMAND"),
      // 75529  21.5 Google Chrome He
      let topProcessRegex = try? NSRegularExpression(pattern: "^(\\d+)\\s+([\\d\\.]+)\\s+(.+)"),
      // Processes: 652 total, 5 running, 647 sleeping, 3732 threads
      let topProcessesEndRegex = try? NSRegularExpression(pattern: "^Processes:")
    else { return }

    let topCommand = Process()
    topCommand.launchPath = "/usr/bin/top"
    topCommand.arguments = [
      "-stats", "pid,cpu,command",
      // Make the top command produce two outputs.
      // The first output is not accurate because the value is at the moment of activation.
      // The second output is the correct value and should be used.
      "-l", "2",
      "-n", "3",
      "-s", "3",
    ]

    topCommand.environment = [
      "LC_ALL": "C"
    ]

    let pipe = Pipe()
    topCommand.standardOutput = pipe

    topCommand.launch()
    topCommand.waitUntilExit()

    if let data = try? pipe.fileHandleForReading.readToEnd() {
      let output = String(decoding: data, as: UTF8.self)
      let lines = output.split(whereSeparator: \.isNewline)

      var inProcessesLine = false
      var newCPUUsage = 0.0
      var newProcesses: [[String: String]] = []

      for lineSubSequence in lines {
        let line = String(lineSubSequence)

        //
        // Parse CPU usage
        //

        let cpuUsages = line.capturedGroups(withRegex: topCPUUsageRegex)
        if cpuUsages.count > 0 {
          newCPUUsage = Double(cpuUsages[0])! + Double(cpuUsages[1])!
        }

        //
        // Parse processes
        //

        if inProcessesLine {
          if topProcessesEndRegex.numberOfMatches(
            in: line, range: NSRange(line.startIndex..., in: line)) > 0
          {
            inProcessesLine = false
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

      await update(cpuUsage: newCPUUsage)
      await update(processes: newProcesses)
    }

    Task {
      await runTopCommand()
    }
  }

  private func update(cpuUsage: Double) async {
    self.cpuUsage = cpuUsage
  }

  private func update(processes: [[String: String]]) async {
    self.processes = processes
  }
}
