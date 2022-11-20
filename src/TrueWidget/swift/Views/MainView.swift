import SwiftUI

struct MainView: View {
  let operatingSystemVersion: String

  @ObservedObject var cpuUsage = WidgetSource.CPUUsage.shared

  var body: some View {
    VStack {
      VStack {
        Text(operatingSystemVersion)

          HStack(alignment: .center, spacing: 0) {
              Image(systemName: "cpu")
                  .font(.custom("Menlo", size: 24.0))

              HStack(alignment: .bottom, spacing: 0) {
            Text(
              String(format: "% 6.2f", cpuUsage.system + cpuUsage.user)
            )
            .font(.custom("Menlo", size: 24.0))

            Text("%")
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
      .previewLayout(.fixed(width: 200.0, height: 100.0))
  }
}
