import SwiftUI

struct MainView: View {
  let operatingSystemVersion: String

  @ObservedObject var cpuUsage = WidgetSource.CPUUsage.shared

  var body: some View {
    VStack {
      VStack {
        Text(operatingSystemVersion)
        Text(
          String(
            format: "CPU: system %.2f%% user %.2f%% idle %.2f%% nice %.2f%%",
            cpuUsage.system,
            cpuUsage.user,
            cpuUsage.idle,
            cpuUsage.nice
          )
        )
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
      .previewLayout(.fixed(width: 200.0, height: 100.0))
  }
}
