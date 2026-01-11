import AppKit
import ServiceManagement
import SwiftUI

struct SettingsAutoVolumeUnmounterView: View {
  @EnvironmentObject private var userSettings: UserSettings
  @Environment(\.scenePhase) private var scenePhase

  @ObservedObject private var autoVolumeUnmounter = ExtraFeatures.AutoVolumeUnmounter.shared
  @State private var daemonStatus = PrivilegedDaemonClient.shared.daemonStatus()

  private static let statusDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()

  var body: some View {
    GroupBox(label: Text("Automatic volume unmounting")) {
      VStack(alignment: .leading, spacing: 12.0) {
        Label(
          "Volumes selected here are automatically unmounted once when TrueWidget launches.",
          systemImage: InfoBorder.icon
        )
        .modifier(InfoBorder())

        if userSettings.autoVolumeUnmounterEnabled && daemonStatus != .enabled {
          Label(
            privilegedDaemonWarningText(),
            systemImage: WarningBorder.icon
          )
          .modifier(WarningBorder())
        }

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
          refreshPrivilegedDaemonStatus()
        }

        if userSettings.autoVolumeUnmounterEnabled {
          if autoVolumeUnmounter.autoUnmountCandidateVolumes.isEmpty {
            Text("No unmountable volumes found.")
              .font(.caption)
          } else {
            List {
              ForEach(autoVolumeUnmounter.autoUnmountCandidateVolumes) { volume in
                VStack(alignment: .leading, spacing: 2) {
                  Toggle(isOn: targetBinding(for: volume.id)) {
                    Label(
                      volume.name,
                      systemImage: volume.isInternal ? "internaldrive" : "externaldrive")
                  }
                  .switchToggleStyle()

                  Label("Volume UUID: \(volume.id)", image: "clear")
                    .textSelection(.enabled)
                    .font(.caption)

                  statusLabel(for: volume.id)
                }
              }
            }
            .frame(height: 300)
          }
        }
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .onAppear {
      refreshPrivilegedDaemonStatus()
    }
    .onChange(of: scenePhase) { phase in
      if phase == .active {
        refreshPrivilegedDaemonStatus()
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
      refreshPrivilegedDaemonStatus()
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

  private func statusLabel(for uuid: String) -> some View {
    let status = autoVolumeUnmounter.volumeStatusByUUID[uuid]

    return Label("Status: \(statusText(status))", image: "clear")
      .textSelection(.enabled)
      .font(.caption)
      .foregroundStyle(
        status == nil ? .secondary : .primary
      )
  }

  private func statusText(_ status: ExtraFeatures.AutoVolumeUnmounter.VolumeStatus?) -> String {
    guard let status else {
      return ""
    }

    if status.kind == .disabled {
      return status.displayText
    } else {
      return status.displayText + " [\(Self.statusDateFormatter.string(from: status.checkedAt))]"
    }
  }

  private func refreshPrivilegedDaemonStatus() {
    daemonStatus = PrivilegedDaemonClient.shared.daemonStatus()
  }

  private func privilegedDaemonWarningText() -> String {
    switch daemonStatus {
    case .requiresApproval:
      return
        "TrueWidget Privileged Daemon is required to unmount volumes. Enable Background Activity in System Settings."
    case .notFound:
      return "Privileged Daemon was not found. Reinstall TrueWidget."
    default:
      return "Privileged Daemon is not running."
    }
  }
}
