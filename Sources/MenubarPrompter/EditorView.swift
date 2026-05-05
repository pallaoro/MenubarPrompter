import AppKit
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

            CocoaTextEditor(text: $store.script)
                .frame(minHeight: 240)
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
                    Slider(value: $store.fontSize, in: 10...60)
                }
            }
        }
        .padding(20)
        .frame(minWidth: 560, minHeight: 380)
    }
}

/// Real NSTextView in a scroll view, wrapped for SwiftUI. Gets ⌘A / ⌘C / ⌘V
/// / ⌘X / ⌘Z natively because NSTextView responds to those selectors out of
/// the box.
struct CocoaTextEditor: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false

        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.usesFindBar = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.string = text
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            // Only assign when out of sync to preserve selection / undo stack.
            textView.string = text
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        init(text: Binding<String>) { _text = text }

        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            if tv.string != text { text = tv.string }
        }
    }
}
