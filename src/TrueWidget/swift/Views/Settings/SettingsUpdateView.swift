import SwiftUI

struct SettingsUpdateView: View {
  let version =
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("Updates")) {
        VStack(alignment: .leading) {
          Text("TrueWidget version \(version)")

          HStack {
            CheckForUpdatesView()

            Spacer()

            CheckForBetaUpdatesView()
          }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      GroupBox(label: Text("Websites")) {
        HStack(spacing: 20.0) {
          Button(
            action: { NSWorkspace.shared.open(URL(string: "https://truewidget.pqrs.org")!) },
            label: {
              Label("Open official website", systemImage: "house")
            })

          Button(
            action: {
              NSWorkspace.shared.open(URL(string: "https://github.com/pqrs-org/TrueWidget")!)
            },
            label: {
              Label("Open GitHub (source code)", systemImage: "network")
            })
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }

  // This additional view is needed for the disabled state on the menu item to work properly before Monterey.
  // See https://stackoverflow.com/questions/68553092/menu-not-updating-swiftui-bug for more information
  struct CheckForUpdatesView: View {
    @ObservedObject var updater = Updater.shared

    var body: some View {
      Button(
        action: { updater.checkForUpdatesStableOnly() },
        label: {
          Label("Check for updates...", systemImage: "star")
        }
      )
      .disabled(!updater.canCheckForUpdates)
    }
  }

  // This additional view is needed for the disabled state on the menu item to work properly before Monterey.
  // See https://stackoverflow.com/questions/68553092/menu-not-updating-swiftui-bug for more information
  struct CheckForBetaUpdatesView: View {
    @ObservedObject var updater = Updater.shared

    var body: some View {
      Button(
        action: { updater.checkForUpdatesWithBetaVersion() },
        label: {
          Label("Check for beta updates...", systemImage: "star.circle")
        }
      )
      .disabled(!updater.canCheckForUpdates)
    }
  }
}
