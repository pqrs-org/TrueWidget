import SwiftUI

struct MainView: View {
  @ObservedObject private var userSettings = UserSettings.shared
  @State private var hidden = false

  var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 10.0) {
        if userSettings.showOperatingSystem {
          MainOperatingSystemView()
        }

        if userSettings.showXcode {
          MainXcodeView()
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
        .fill(.black)
    )
    .foregroundColor(.white)
    .opacity(hidden ? 0.0 : userSettings.widgetOpacity)
    .whenHovered { hover in
      hidden = hover
    }
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(.black, lineWidth: 4)
    )
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
      .previewLayout(.sizeThatFits)
  }
}
