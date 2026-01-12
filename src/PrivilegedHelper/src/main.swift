import Foundation
import ServiceManagement

enum Subcommand: String {
  case register = "register"
  case unregister = "unregister"
  case enabled = "enabled"
}

RunLoop.main.perform {
  let daemonServiceNames = [
    "org.pqrs.TrueWidget.PrivilegedDaemon"
  ]

  let daemons = daemonServiceNames.map {
    SMAppService.daemon(plistName: "\($0).plist")
  }

  if CommandLine.arguments.count > 1 {
    let subcommand = CommandLine.arguments[1]

    switch Subcommand(rawValue: subcommand) {
    case .register:
      ServiceManagementHelper.register(services: daemons)
      exit(0)

    case .unregister:
      ServiceManagementHelper.unregister(services: daemons)
      exit(0)

    case .enabled:
      if ServiceManagementHelper.enabled(services: daemons) {
        print("enabled")
        exit(0)
      } else {
        print("There are services that are not enabled")
        exit(1)
      }

    default:
      print("Unknown subcommand \(subcommand)")
      exit(1)
    }
  }

  print("Usage:")
  print("    'TrueWidget Privileged Helper' subcommand")
  print("")
  print("Subcommands:")
  print("    \(Subcommand.register.rawValue)")
  print("    \(Subcommand.unregister.rawValue)")
  print("    \(Subcommand.enabled.rawValue)")

  exit(0)
}

RunLoop.main.run()
