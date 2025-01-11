import Foundation

struct TopCommandData {
  var cpuUsage: Double = 0.0
  var processes: [[String: String]] = []
}

enum TopCommandError: Error {
  case invalidRegexp
}

func topCommandStream() -> AsyncThrowingStream<TopCommandData, Error> {
  return AsyncThrowingStream { continuation in
    guard
      // CPU usage: 10.84% user, 8.27% sys, 80.88% idle
      let topCPUUsageRegex = try? NSRegularExpression(
        pattern: "^CPU usage: ([\\d\\.]+)% user, ([\\d\\.]+)% sys, "),
      // %CPU COMMAND
      let topProcessesStartRegex = try? NSRegularExpression(pattern: "^%CPU\\s+COMMAND"),
      // 21.5 Google Chrome He
      let topProcessRegex = try? NSRegularExpression(pattern: "^([\\d\\.]+)\\s+(.+)")
    else {
      continuation.finish(throwing: TopCommandError.invalidRegexp)
      return
    }

    let process = Process()
    let pipe = Pipe()

    process.launchPath = "/usr/bin/top"
    process.arguments = [
      "-stats", "cpu,command",
      // infinity loop
      "-l", "0",
      // 3 processes
      "-n", "3",
      // 3 second interval
      "-s", "3",
    ]
    process.environment = [
      "LC_ALL": "C"
    ]
    process.standardOutput = pipe

    let task = Task {
      do {
        var inProcessesLine = false
        var data = TopCommandData()

        for try await line in pipe.fileHandleForReading.bytes.lines {
          if Task.isCancelled {
            process.terminate()
            continuation.finish()
            break
          }

          //
          // Parse CPU usage
          //

          let cpuUsages = line.capturedGroups(withRegex: topCPUUsageRegex)
          if cpuUsages.count > 0,
            let user = Double(cpuUsages[0]),
            let sys = Double(cpuUsages[1])
          {
            data.cpuUsage = user + sys
          }

          //
          // Parse processes
          //

          if inProcessesLine {
            let process = line.capturedGroups(withRegex: topProcessRegex)
            if process.count > 0 {
              data.processes.append(
                [
                  "cpu": process[0],
                  "name": process[1].trimmingCharacters(in: .whitespacesAndNewlines),
                ]
              )

              if data.processes.count >= 3 {
                continuation.yield(data)

                inProcessesLine = false
                data = TopCommandData()
              }
            }
          }

          if topProcessesStartRegex.numberOfMatches(
            in: line, range: NSRange(line.startIndex..., in: line)) > 0
          {
            inProcessesLine = true
          }
        }
      } catch {
        continuation.finish(throwing: error)
      }
    }

    process.terminationHandler = { _ in
      continuation.finish()
    }

    do {
      try process.run()
    } catch {
      continuation.finish(throwing: error)
    }

    continuation.onTermination = { _ in
      process.terminate()
      task.cancel()
    }
  }
}
