import SwiftUI

struct CompactTimeView: View {
  @ObservedObject private var userSettings: UserSettings
  @StateObject private var time: WidgetSource.Time

  init(userSettings: UserSettings) {
    self.userSettings = userSettings
    _time = StateObject(wrappedValue: WidgetSource.Time(userSettings: userSettings))
  }

  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      Spacer()

      HStack(alignment: .firstTextBaseline, spacing: 0) {
        Text(
          time.localTime == nil
            ? "---"
            : String(
              format: "%02d:%02d:%02d",
              time.localTime?.hour ?? 0,
              time.localTime?.minute ?? 0,
              time.localTime?.second ?? 0
            )
        )
        .font(.custom("Menlo", size: userSettings.compactLocalTimeFontSize))
      }
    }
    .onDisappear {
      time.cancelTimer()
    }
  }
}
