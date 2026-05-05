import AppKit

@main
@MainActor
enum MenubarPrompterApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.regular)
        app.run()
        _ = delegate // keep delegate alive for the lifetime of the app
    }
}
