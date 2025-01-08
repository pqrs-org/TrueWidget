import SwiftUI
import UniformTypeIdentifiers

struct BundlePickerView: View {
  @Binding private(set) var selectedFileURL: URL?

  @State private var isPickingFile = false
  @State private var errorMessage: String?

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text("\(selectedFileURL?.path  ?? "---")")
          .fixedSize(horizontal: false, vertical: true)

        if let error = errorMessage {
          Text(error)
            .foregroundColor(Color.errorForeground)
            .background(Color.errorBackground)
        }
      }

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
          if let url = try result.get().first {
            if WidgetSource.Bundle.BundleVersion(url) != nil {
              selectedFileURL = url
              errorMessage = nil
              return
            }
          }

          errorMessage = "Could not get the version of the selected file"
        } catch {
          errorMessage = "File selection failed: \(error.localizedDescription)"
        }
      }

      Button(
        role: .destructive,
        action: {
          selectedFileURL = nil
          errorMessage = nil
        }
      ) {
        Label("Reset", systemImage: "trash")
          .labelStyle(.iconOnly)
          .foregroundColor(.red)
      }
    }
  }
}
