import DiskArbitration
import Foundation

print("show-volumes")

guard let session = DASessionCreate(kCFAllocatorDefault) else {
  fatalError("DASessionCreate failed")
}

func diskutilApfsListPlist() -> Data? {
  let process = Process()
  process.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")
  process.arguments = ["apfs", "list", "-plist"]

  let outputPipe = Pipe()
  let errorPipe = Pipe()
  process.standardOutput = outputPipe
  process.standardError = errorPipe

  do {
    try process.run()
  } catch {
    print("diskutil run failed: \(error.localizedDescription)")
    return nil
  }

  let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
  let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
  process.waitUntilExit()

  if process.terminationStatus != 0 {
    if let errorText = String(data: errorData, encoding: .utf8), !errorText.isEmpty {
      print("diskutil failed: \(errorText)")
    } else {
      print("diskutil failed")
    }
    return nil
  }

  return outputData
}

guard let data = diskutilApfsListPlist() else {
  exit(1)
}

guard
  let plist = try? PropertyListSerialization.propertyList(
    from: data,
    options: [],
    format: nil
  ),
  let root = plist as? [String: Any]
else {
  print("diskutil plist parse failed")
  exit(1)
}

var bsdNames: Set<String> = []
for container in root["Containers"] as? [[String: Any]] ?? [] {
  for volume in container["Volumes"] as? [[String: Any]] ?? [] {
    if let device = volume["DeviceIdentifier"] as? String, !device.isEmpty {
      bsdNames.insert(device)
    }
  }
}

for bsdName in bsdNames.sorted() {
  guard let disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session, bsdName) else {
    continue
  }

  guard let description = DADiskCopyDescription(disk) else {
    continue
  }

  print("=== \(bsdName) ===")
  if let desc = CFCopyDescription(description) as String? {
    print(desc)
  }
}
