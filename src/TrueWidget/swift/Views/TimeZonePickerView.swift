import SwiftUI

struct TimeZonePickerView: View {
  class Source: ObservableObject {
    class TZ: Identifiable {
      let id = UUID()
      let abbreviation: String  // JST
      let identifier: String  // Asia/Tokyo
      let label: String

      init(abbreviation: String, identifier: String) {
        self.abbreviation = abbreviation
        self.identifier = identifier

        if abbreviation == identifier {
          label = abbreviation
        } else {
          label =
            "\(abbreviation.padding(toLength: 7, withPad: " ", startingAt: 0))\t(\(identifier))"
        }
      }
    }

    static let shared = Source()

    var timeZones: [TZ] = []

    init() {
      TimeZone.abbreviationDictionary.forEach { d in
        let abbreviation = d.key
        let identifier = d.value
        timeZones.append(TZ(abbreviation: abbreviation, identifier: identifier))
      }

      timeZones.sort { return $0.abbreviation < $1.abbreviation }
    }
  }

  @ObservedObject private var source = Source.shared
  @Binding private(set) var abbreviation: String

  var body: some View {
    Picker("", selection: $abbreviation) {
      ForEach(source.timeZones) { timeZone in
        Text(timeZone.label)
          .tag(timeZone.abbreviation)
      }
    }
    .pickerStyle(.menu)
  }
}
