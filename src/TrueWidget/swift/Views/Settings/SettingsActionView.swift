import SwiftUI

struct SettingsActionView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("Action")) {
        VStack(alignment: .leading, spacing: 16) {
          Button(
            action: {
              Relauncher.relaunch()
            },
            label: {
              Label("Restart TrueWidget", systemImage: "arrow.clockwise")
            })

          Button(
            action: {
              NSApplication.shared.terminate(self)
            },
            label: {
              Label("Quit TrueWidget", systemImage: "xmark.circle.fill")
            })
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}
