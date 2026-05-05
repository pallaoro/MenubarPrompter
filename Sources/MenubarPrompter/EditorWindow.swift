import AppKit
import SwiftUI

@MainActor
final class EditorWindow: NSWindow {
    init(store: PrompterStore) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 480),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        title = "Edit Script"
        isReleasedWhenClosed = false
        contentView = NSHostingView(rootView: EditorView(store: store))
        center()
    }
}
