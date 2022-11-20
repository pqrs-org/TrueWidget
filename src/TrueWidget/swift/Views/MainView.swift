import SwiftUI

struct MainView: View {
  let operatingSystemVersion: String

  @ObservedObject var cpuUsage = WidgetSource.CPUUsage.shared
  @ObservedObject var localTime = WidgetSource.LocalTime.shared

  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        Text(operatingSystemVersion)

        HStack(alignment: .center, spacing: 0) {
          Image(systemName: "cpu")
            .font(.custom("Menlo", size: 24.0))

          Spacer()

          HStack(alignment: .bottom, spacing: 0) {
            Text(
              String(format: "% 6.2f", cpuUsage.system + cpuUsage.user)
            )
            .font(.custom("Menlo", size: 24.0))

            Text("%")
          }

        }

        HStack(alignment: .center, spacing: 0) {
          Image(systemName: "clock")
            .font(.custom("Menlo", size: 24.0))

          Spacer()

          HStack(alignment: .center, spacing: 0) {
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
                format: ":%02d",
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
      minWidth: 0,
      maxWidth: .infinity,
      minHeight: 0,
      maxHeight: .infinity,
      alignment: .center
    )
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(NSColor.black))
    )
    .foregroundColor(Color.white)
    .opacity(0.5)
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView(operatingSystemVersion: "macOS 98.76.54 (Build 99A999)")
      .previewLayout(.fixed(width: 250.0, height: 100.0))
  }
}
