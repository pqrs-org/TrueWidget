import SwiftUI

struct MainView: View {
  @ObservedObject private var userSettings = UserSettings.shared
  @ObservedObject private var operatingSystem = WidgetSource.OperatingSystem.shared
  @ObservedObject private var cpuUsage = WidgetSource.CPUUsage.shared
  @ObservedObject private var localTime = WidgetSource.LocalTime.shared
  @State private var opacity = 0.8

  var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 10.0) {
        //
        // Operating system
        //

        if userSettings.showOperatingSystem {
          HStack(alignment: .center, spacing: 0) {
            Text("macOS ")
            Text(operatingSystem.version)
            Spacer()
            Text(operatingSystem.hostName)
          }
          .font(.system(size: userSettings.operatingSystemFontSize))
        }

        //
        // CPU usage
        //

        if userSettings.showCPUUsage {
          HStack(alignment: .center, spacing: 0) {
            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 0) {
              Text("CPU")
                .font(.system(size: userSettings.cpuUsageFontSize / 2))

              Text(String(format: "% 3d", cpuUsage.usageInteger))

              Text(String(format: ".%02d%%", cpuUsage.usageDecimal))
                .font(.custom("Menlo", size: userSettings.cpuUsageFontSize / 2))
            }
          }
          .font(.custom("Menlo", size: userSettings.cpuUsageFontSize))
        }

        //
        // Local time
        //

        if userSettings.showLocalTime {
          HStack(alignment: .center, spacing: 0) {
            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 0) {
              Text(
                String(
                  format: " %02d:%02d",
                  localTime.hour,
                  localTime.minute
                )
              )
              .font(.custom("Menlo", size: userSettings.localTimeFontSize))

              Text(
                String(
                  format: " %02d",
                  localTime.second
                )
              )
              .font(.custom("Menlo", size: userSettings.localTimeFontSize / 2))
            }
          }
        }
      }
      .padding(.horizontal, 20.0)
      .padding(.vertical, 10.0)
    }
    .frame(
      alignment: .center
    )
    .frame(width: userSettings.widgetWidth)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(NSColor.black))
    )
    .foregroundColor(Color.white)
    .opacity(opacity)
    .whenHovered { hover in
      opacity = hover ? 0.2 : 0.8
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
      .previewLayout(.sizeThatFits)
  }
}
