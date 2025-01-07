import SwiftUI
import UniformTypeIdentifiers

struct BundlePickerView: View {
  @Binding private(set) var selectedFileURL: URL?

  @State private var isPickingFile = false
  @State private var errorMessage: String?

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("\(selectedFileURL?.path  ?? "---")")
          .fixedSize(horizontal: false, vertical: true)

        Spacer()

        Button("Select") {
          isPickingFile = true
        }
        .fileImporter(
          isPresented: $isPickingFile,
          allowedContentTypes: [.item],
          allowsMultipleSelection: false
        ) { result in
          do {
            guard let url = try result.get().first else { return }
            if WidgetSource.Bundle.BundleVersion(url) != nil {
              errorMessage = nil
              selectedFileURL = url
            } else {
              errorMessage = "Could not get the version of the selected file"
            }
          } catch {
            errorMessage = "File selection failed: \(error.localizedDescription)"
          }
        }

        Button(
          role: .destructive,
          action: {
            selectedFileURL = nil
          }
        ) {
          Label("Reset", systemImage: "trash")
            .labelStyle(.iconOnly)
            .foregroundColor(.red)
        }
      }

      if let error = errorMessage {
        Text(error)
          .foregroundColor(Color.errorForeground)
          .background(Color.errorBackground)
      }
    }
  }
}
