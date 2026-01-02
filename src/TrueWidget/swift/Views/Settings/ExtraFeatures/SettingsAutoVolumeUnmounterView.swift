import SwiftUI

struct SettingsAutoVolumeUnmounterView: View {
  @EnvironmentObject private var userSettings: UserSettings

  @ObservedObject private var autoVolumeUnmounter = ExtraFeatures.AutoVolumeUnmounter.shared

  var body: some View {
    GroupBox(label: Text("Automatic volume unmounting")) {
      VStack(alignment: .leading, spacing: 12.0) {
        Label(
          "Volumes selected here are automatically unmounted once when TrueWidget launches.",
          systemImage: InfoBorder.icon
        )
        .modifier(InfoBorder())

        Toggle(isOn: $userSettings.autoVolumeUnmounterEnabled) {
          Text("Enable automatic volume unmounting")
        }
        .switchToggleStyle()
        .onChange(of: userSettings.autoVolumeUnmounterEnabled) { isEnabled in
          if isEnabled {
            autoVolumeUnmounter.start()
          } else {
            autoVolumeUnmounter.stop()
          }
        }

        if userSettings.autoVolumeUnmounterEnabled {
          if autoVolumeUnmounter.autoUnmountCandidateVolumes.isEmpty {
            Text("No unmountable volumes found.")
              .font(.caption)
          } else {
            List {
              ForEach(autoVolumeUnmounter.autoUnmountCandidateVolumes) { volume in
                Toggle(isOn: targetBinding(for: volume.id)) {
                  VStack(alignment: .leading, spacing: 2) {
                    Label(
                      volume.name,
                      systemImage: volume.isInternal ? "internaldrive" : "externaldrive")

                    Label("Volume UUID: \(volume.id)", image: "clear")
                      .textSelection(.enabled)
                      .font(.caption)

                    Label(
                      volume.path != ""
                        ? "Path: \(volume.path)"
                        : "Unmounted",
                      image: "clear"
                    )
                    .textSelection(.enabled)
                    .font(.caption)
                  }
                }
                .switchToggleStyle()
              }
            }
            .frame(height: 300)
          }
        }
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func targetBinding(for uuid: String) -> Binding<Bool> {
    Binding(
      get: {
        userSettings.autoVolumeUnmounterTargetVolumeUUIDs.contains(uuid)
      },
      set: { isOn in
        var targets = userSettings.autoVolumeUnmounterTargetVolumeUUIDs
        if isOn {
          if !targets.contains(uuid) {
            targets.append(uuid)
          }
        } else {
          targets.removeAll { $0 == uuid }
        }
        userSettings.autoVolumeUnmounterTargetVolumeUUIDs = targets
      }
    )
  }
}
