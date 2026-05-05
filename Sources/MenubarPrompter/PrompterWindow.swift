import AppKit
import SwiftUI

@MainActor
final class PrompterWindow: NSPanel {
    private let store: PrompterStore
    private let bodyContentHeight: CGFloat = 100
    private let scoopHeight: CGFloat = 22
    private let bottomRadius: CGFloat = 24
    /// Last-seen menu-bar height when the menu bar was visible. Used as the
    /// wing height in full-screen mode (when the menu bar is hidden).
    private var referenceMenuBarHeight: CGFloat = 24
    private var observers: [NSObjectProtocol] = []

    init(store: PrompterStore) {
        self.store = store

        let initialHeight = scoopHeight + bodyContentHeight + bottomRadius
        let initial = NSRect(x: 0, y: 0, width: 420, height: initialHeight)
        super.init(
            contentRect: initial,
            // .nonactivatingPanel is required to overlay other apps'
            // full-screen Spaces. Side-effect: the app stays in the
            // background when the bubble is clicked, so the local key-event
            // monitor doesn't fire. In v0.1 keyboard shortcuts are therefore
            // only effective when the app is the frontmost app (e.g. via
            // the Dock or Cmd-Tab).
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        // .screenSaver (1000) is above the system "shielding" level used by
        // macOS for full-screen apps, so the bubble paints over them too.
        level = .screenSaver
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isMovable = false
        isMovableByWindowBackground = false
        isReleasedWhenClosed = false
        sharingType = .none
        hidesOnDeactivate = false
        canHide = false
        worksWhenModal = true

        contentView = NSHostingView(rootView: PrompterView(store: store))

        // Active-space change fires whenever the user swipes between Spaces,
        // including in/out of a full-screen app's Space.
        observers.append(
            NSWorkspace.shared.notificationCenter.addObserver(
                forName: NSWorkspace.activeSpaceDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated { self?.scheduleSync() }
            }
        )

        // Frontmost-app change is a strong proxy for entering/leaving a
        // full-screen Space (each full-screen app lives in its own Space and
        // has its own frontmost transition).
        observers.append(
            NSWorkspace.shared.notificationCenter.addObserver(
                forName: NSWorkspace.didActivateApplicationNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated { self?.scheduleSync() }
            }
        )

        syncWithCurrentSpace()
    }

    deinit {
        for o in observers {
            NotificationCenter.default.removeObserver(o)
            NSWorkspace.shared.notificationCenter.removeObserver(o)
        }
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    /// Manual scroll: the SwiftUI text view doesn't handle scroll events on
    /// its own, so they bubble up to the window. We use the y delta to nudge
    /// the prompter offset, letting the user jump to a specific line.
    override func scrollWheel(with event: NSEvent) {
        let delta = event.scrollingDeltaY
        if delta != 0 {
            // scrollingDeltaY follows the system's "natural" scrolling
            // setting: fingers up → positive → reveal upcoming lines.
            store.scroll(by: delta)
        } else {
            super.scrollWheel(with: event)
        }
    }

    /// Defer the sync slightly so AppKit has time to settle the new state
    /// (NSScreen / presentation options can lag the notification by a frame).
    private func scheduleSync() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.syncWithCurrentSpace()
        }
    }

    /// Recompute wing height + window size based on whether the menu bar is
    /// currently visible (normal Space) or hidden (full-screen Space).
    private func syncWithCurrentSpace() {
        guard let screen = NSScreen.main else { return }

        let opts = NSApplication.shared.currentSystemPresentationOptions
        let menuBarHidden =
            opts.contains(.fullScreen) ||
            opts.contains(.autoHideMenuBar) ||
            opts.contains(.hideMenuBar)

        if !menuBarHidden {
            // Normal Space: sample the live menu-bar height for later use,
            // and keep the bubble flush at the top with no wing.
            let measured = screen.frame.maxY - screen.visibleFrame.maxY
            if measured > 0 { referenceMenuBarHeight = measured }
            store.wingHeight = 0
        } else {
            // Full-screen Space: pad the bubble with a wing the size of the
            // (now-hidden) menu bar so the scoops sit at the same y position.
            store.wingHeight = referenceMenuBarHeight
        }

        let totalHeight = store.wingHeight + scoopHeight + bodyContentHeight + bottomRadius
        let screenFrame = screen.frame
        let x = screenFrame.midX - frame.width / 2
        let y = screenFrame.maxY - totalHeight
        setFrame(NSRect(x: x, y: y, width: frame.width, height: totalHeight),
                 display: true,
                 animate: false)
    }
}
