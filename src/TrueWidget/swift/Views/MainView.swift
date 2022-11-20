import SwiftUI

struct MainView: View {
  @ObservedObject var operatingSystem = WidgetSource.OperatingSystem.shared
  @ObservedObject var cpuUsage = WidgetSource.CPUUsage.shared
  @ObservedObject var localTime = WidgetSource.LocalTime.shared

  var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 0.0) {
        HStack(alignment: .center, spacing: 0) {
          Text("macOS")
          Text(operatingSystem.version)
        }

        Divider()
          .padding(.vertical, 4.0)

        HStack(alignment: .center, spacing: 0) {
          Image(systemName: "cpu")
            .font(.custom("Menlo", size: 24.0))

          Spacer()

          HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(String(format: "%d", cpuUsage.usageInteger))
              .font(.custom("Menlo", size: 36.0))

            Text(String(format: ".%02d%%", cpuUsage.usageDecimal))
              .font(.custom("Menlo", size: 14.0))
          }
        }

        Divider()
          .padding(.vertical, 4.0)

        HStack(alignment: .center, spacing: 0) {
          Image(systemName: "clock")
            .font(.custom("Menlo", size: 24.0))

          Spacer()

          HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(
              String(
                format: " %02d:%02d",
                localTime.hour,
                localTime.minute
              )
            )
            .font(.custom("Menlo", size: 36.0))

            Text(
              String(
                format: " %02d",
                localTime.second
              )
            )
            .font(.custom("Menlo", size: 14.0))
          }
        }
      }
      .padding(.horizontal, 20.0)
      .padding(.vertical, 10.0)
    }
    .frame(
      alignment: .center
    )
    .frame(width: 250.0)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(NSColor.black))
    )
    .foregroundColor(Color.white)
    .opacity(0.8)
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
      .previewLayout(.sizeThatFits)
  }
}
