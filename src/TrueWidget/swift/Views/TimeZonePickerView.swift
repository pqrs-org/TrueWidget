import SwiftUI

struct TimeZonePickerView: View {
  class Source: ObservableObject {
    struct TimeZoneEntry: Identifiable {
      let id = UUID()
      let abbreviation: String  // JST
      let identifier: String  // Asia/Tokyo
      let secondsFromGMT: Int
      let label: String

      init(abbreviation: String, identifier: String) {
        self.abbreviation = abbreviation
        self.identifier = identifier

        let timeZone = TimeZone(identifier: identifier)
        secondsFromGMT = timeZone?.secondsFromGMT() ?? 0
        let minutesFromGMT = abs(secondsFromGMT) / 60

        var label = String(
          format: "GMT%@%02d:%02d\t",
          secondsFromGMT < 0 ? "-" : "+",
          minutesFromGMT / 60,
          minutesFromGMT % 60
        )

        if abbreviation == identifier {
          label = "\(label)\(abbreviation)"
        } else {
          label =
            "\(label)\(abbreviation.padding(toLength: 7, withPad: " ", startingAt: 0))\t(\(identifier))"
        }

        self.label = label
      }
    }

    static let shared = Source()

    var timeZones: [TimeZoneEntry] = []

    init() {
      TimeZone.abbreviationDictionary.forEach { d in
        let abbreviation = d.key
        let identifier = d.value
        timeZones.append(TimeZoneEntry(abbreviation: abbreviation, identifier: identifier))
      }

      timeZones.sort {
        if $0.secondsFromGMT != $1.secondsFromGMT {
          return $0.secondsFromGMT < $1.secondsFromGMT
        }
        return $0.abbreviation < $1.abbreviation
      }
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
