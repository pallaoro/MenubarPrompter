import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = PrompterStore()
    private var prompterWindow: PrompterWindow?
    private var editorWindow: EditorWindow?
    private var keyMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let win = PrompterWindow(store: store)
        win.makeKeyAndOrderFront(nil)
        prompterWindow = win

        NSApp.activate(ignoringOtherApps: true)
        installMainMenu()
        installKeyMonitor()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    deinit {
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
        }
    }

    @objc func togglePlay() { store.togglePlay() }
    @objc func restart() { store.restart() }
    @objc func speedUp() { store.adjustSpeed(by: 5) }
    @objc func slowDown() { store.adjustSpeed(by: -5) }
    @objc func showPrompter() { prompterWindow?.makeKeyAndOrderFront(nil) }

    @objc func openEditor() {
        if editorWindow == nil {
            editorWindow = EditorWindow(store: store)
        }
        editorWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func installMainMenu() {
        let mainMenu = NSMenu()

        let appItem = NSMenuItem()
        mainMenu.addItem(appItem)
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About Menubar Prompter",
                        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
                        keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Hide",
                        action: #selector(NSApplication.hide(_:)),
                        keyEquivalent: "h")
        appMenu.addItem(withTitle: "Quit",
                        action: #selector(NSApplication.terminate(_:)),
                        keyEquivalent: "q")
        appItem.submenu = appMenu

        let prompterItem = NSMenuItem()
        mainMenu.addItem(prompterItem)
        let prompterMenu = NSMenu(title: "Prompter")
        let playItem = prompterMenu.addItem(withTitle: "Play / Pause",
                                            action: #selector(togglePlay),
                                            keyEquivalent: "p")
        playItem.target = self
        let restartItem = prompterMenu.addItem(withTitle: "Restart",
                                               action: #selector(restart),
                                               keyEquivalent: "r")
        restartItem.target = self
        prompterMenu.addItem(.separator())
        let editItem = prompterMenu.addItem(withTitle: "Edit Script…",
                                            action: #selector(openEditor),
                                            keyEquivalent: "e")
        editItem.target = self
        prompterMenu.addItem(.separator())
        let showItem = prompterMenu.addItem(withTitle: "Show Prompter",
                                            action: #selector(showPrompter),
                                            keyEquivalent: "1")
        showItem.target = self
        prompterItem.submenu = prompterMenu

        NSApp.mainMenu = mainMenu
    }

    private func installKeyMonitor() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            // Only intercept when the prompter window is the key window — this lets the
            // editor's TextEditor receive Space/letters normally.
            guard let key = NSApp.keyWindow, key === self.prompterWindow else { return event }
            let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            guard mods.isEmpty || mods == .shift else { return event }

            let chars = event.charactersIgnoringModifiers ?? ""
            switch chars {
            case " ":
                self.store.togglePlay()
                return nil
            case "r", "R":
                self.store.restart()
                return nil
            case "e", "E":
                self.openEditor()
                return nil
            default:
                break
            }

            switch event.specialKey {
            case .upArrow?:
                self.store.adjustSpeed(by: 5)
                return nil
            case .downArrow?:
                self.store.adjustSpeed(by: -5)
                return nil
            default:
                return event
            }
        }
    }
}
