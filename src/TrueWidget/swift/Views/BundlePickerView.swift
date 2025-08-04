import SwiftUI
import UniformTypeIdentifiers

struct BundlePickerView: View {
  @Binding private(set) var path: String

  @State private var isPickingFile = false
  @State private var errorMessage: String?

  init(path: Binding<String>) {
    self._path = path
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text("\(path.isEmpty ? "---"  : path)")
          .fixedSize(horizontal: false, vertical: true)

        if let error = errorMessage {
          Label(
            error,
            systemImage: ErrorBorder.icon
          )
          .modifier(ErrorBorder())
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
        if let url = try? result.get().first {
          HelperClient.shared.proxy?.bundleVersions(paths: [url.path]) { versions in
            // Update path on the main thread, as it could be an object observed by the view.
            Task { @MainActor in
              if versions[url.path] != nil {
                path = url.path
                errorMessage = nil
              } else {
                path = ""
                errorMessage = "Could not get the version of the selected file"
              }
            }
          }
          return
        }

        path = ""
        errorMessage = "File selection failed"
      }

      Button(
        role: .destructive,
        action: {
          path = ""
          errorMessage = nil
        },
        label: {
          Label("Reset", systemImage: "trash")
            .labelStyle(.iconOnly)
            .foregroundColor(.red)
        }
      )
    }
  }
}
