import SwiftUI

struct MainView: View {
  let operatingSystemVersion: String
  var body: some View {
    VStack {
      Text(operatingSystemVersion)
        .foregroundColor(Color.white)
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
    .opacity(0.5)
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView(operatingSystemVersion: "macOS 98.76.54 (Build 99A999)")
      .previewLayout(.fixed(width: 200.0, height: 100.0))
  }
}
