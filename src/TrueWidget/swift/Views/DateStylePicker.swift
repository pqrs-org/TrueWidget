import SwiftUI

struct DateStylePicker: View {
  @EnvironmentObject private var userSettings: UserSettings

  var body: some View {
    Picker(
      selection: $userSettings.dateStyle,
      label: Text("Date style:")
    ) {
      Text("RFC 3339").tag(DateStyle.rfc3339.rawValue)
      Text("RFC 3339 with the day of the week (Default)").tag(
        DateStyle.rfc3339WithDayName.rawValue)
      Text("Short").tag(DateStyle.short.rawValue)
      Text("Short with the day of the week").tag(DateStyle.shortWithDayName.rawValue)
      Text("Medium").tag(DateStyle.medium.rawValue)
      Text("Medium with the day of the week").tag(DateStyle.mediumWithDayName.rawValue)
      Text("Long").tag(DateStyle.long.rawValue)
      Text("Long with the day of the week").tag(DateStyle.longWithDayName.rawValue)
      Text("Full").tag(DateStyle.full.rawValue)
    }
  }
}
