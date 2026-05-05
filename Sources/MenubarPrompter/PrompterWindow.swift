import AppKit
import SwiftUI

@MainActor
final class PrompterWindow: NSWindow {
    init(store: PrompterStore) {
        let initial = NSRect(x: 0, y: 0, width: 520, height: 150)
        super.init(
            contentRect: initial,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        // .statusBar (25) sits one above .mainMenu (24), so the bubble paints
        // over the menu bar at the top of the screen and stays visible when
        // other apps come forward.
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        isMovable = false
        isMovableByWindowBackground = false
        isReleasedWhenClosed = false
        sharingType = .none
        hidesOnDeactivate = false
        canHide = false

        contentView = NSHostingView(rootView: PrompterView(store: store))
        positionAtTopOfScreen()
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    func positionAtTopOfScreen() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        let w = frame.width
        let h = frame.height
        let x = screenFrame.midX - w / 2
        let y = screenFrame.maxY - h
        setFrameOrigin(NSPoint(x: x, y: y))
    }
}
