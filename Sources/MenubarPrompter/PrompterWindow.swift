import AppKit
import SwiftUI

@MainActor
final class PrompterWindow: NSWindow {
    init(store: PrompterStore) {
        let initial = NSRect(x: 0, y: 0, width: 760, height: 220)
        super.init(
            contentRect: initial,
            styleMask: [.borderless, .resizable],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        isMovableByWindowBackground = true
        isReleasedWhenClosed = false
        sharingType = .none
        minSize = NSSize(width: 380, height: 120)

        contentView = NSHostingView(rootView: PrompterView(store: store))
        positionUnderMenuBar()
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    func positionUnderMenuBar() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame
        let w = frame.width
        let h = frame.height
        let x = screenFrame.midX - w / 2
        let y = visibleFrame.maxY - h - 6
        setFrameOrigin(NSPoint(x: x, y: y))
    }
}
