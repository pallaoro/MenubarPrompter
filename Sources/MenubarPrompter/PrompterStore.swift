import Foundation
import Observation

@MainActor
@Observable
final class PrompterStore {
    var script: String {
        didSet { UserDefaults.standard.set(script, forKey: "mp.script") }
    }
    var scrollSpeed: Double {
        didSet { UserDefaults.standard.set(scrollSpeed, forKey: "mp.scrollSpeed") }
    }
    var fontSize: Double {
        didSet { UserDefaults.standard.set(fontSize, forKey: "mp.fontSize") }
    }

    var isPlaying: Bool = false

    /// Height of the flat wing above the concave scoops. 0 in normal mode
    /// (the visible menu bar fills that role); equals the menu-bar height in
    /// full-screen mode so the scoops sit at the same on-screen position.
    var wingHeight: CGFloat = 0

    private(set) var baseOffset: CGFloat = 0
    private(set) var baseDate: Date = .init()

    init() {
        let d = UserDefaults.standard
        self.script = d.string(forKey: "mp.script") ?? Self.defaultScript
        self.scrollSpeed = (d.object(forKey: "mp.scrollSpeed") as? Double) ?? 30
        self.fontSize = (d.object(forKey: "mp.fontSize") as? Double) ?? 18
    }

    func currentOffset(at date: Date) -> CGFloat {
        guard isPlaying else { return baseOffset }
        let elapsed = max(0, date.timeIntervalSince(baseDate))
        return baseOffset + CGFloat(elapsed * scrollSpeed)
    }

    func togglePlay() {
        rebase()
        isPlaying.toggle()
    }

    func restart() {
        baseOffset = 0
        baseDate = .init()
    }

    func adjustSpeed(by delta: Double) {
        rebase()
        scrollSpeed = max(5, min(240, scrollSpeed + delta))
    }

    private func rebase() {
        baseOffset = currentOffset(at: .init())
        baseDate = .init()
    }

    static let defaultScript = """
    Welcome to Menubar Prompter.

    Position this window right under your camera —
    so you keep eye contact and stay on track.

    Press Space to play or pause.
    Press Up or Down to change speed.
    Press R to restart. Press E to edit this script.
    """
}
