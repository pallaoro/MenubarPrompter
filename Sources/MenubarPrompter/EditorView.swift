import SwiftUI

struct EditorView: View {
    @Bindable var store: PrompterStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Script").font(.headline)
                Spacer()
                Button("Reset to sample") {
                    store.script = PrompterStore.defaultScript
                }
            }

            TextEditor(text: $store.script)
                .font(.system(size: 14, design: .monospaced))
                .frame(minHeight: 240)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(nsColor: .textBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.3))
                )

            Divider()

            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Speed: \(Int(store.scrollSpeed)) px/s")
                        .font(.subheadline)
                    Slider(value: $store.scrollSpeed, in: 5...240)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Font size: \(Int(store.fontSize)) pt")
                        .font(.subheadline)
                    Slider(value: $store.fontSize, in: 14...60)
                }
            }
        }
        .padding(20)
        .frame(minWidth: 560, minHeight: 380)
    }
}
