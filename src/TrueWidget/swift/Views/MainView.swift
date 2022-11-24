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
        if userSettings.showOperatingSystem {
          MainOperatingSystemView()
        }

        if userSettings.showCPUUsage {
          MainCPUUsageView()
        }

        if userSettings.showLocalTime {
          MainLocalTimeView()
        }
      }
      .padding()
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
