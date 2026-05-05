# Menubar Prompter

A minimal open-source teleprompter for macOS. Pins itself to the very top of the screen — flush under the camera — so you keep eye contact while you read.

## Download

Grab the latest build from the [Releases page](https://github.com/pallaoro/MenubarPrompter/releases).

1. Download `MenubarPrompter-<version>.dmg`.
2. Open it and drag **Menubar Prompter** into the Applications folder shown.
3. **First launch**: right-click the app in `/Applications` → **Open** → confirm the Gatekeeper prompt.

The app is not signed by Apple yet, so macOS asks for confirmation the first time. If macOS refuses to open it at all (newer Gatekeeper versions), run once in Terminal:

```bash
xattr -cr "/Applications/Menubar Prompter.app"
```

Requires macOS 14 or newer.

<img width="750" height="305" alt="Image" src="https://github.com/user-attachments/assets/6beea97b-042d-4410-972b-4e9da62a33c2" />

## Features

- Black bubble pinned to the very top of the screen, painted over the menu bar zone
- Stays visible across app and Space switches
- Hidden from screen sharing and screen recording (`NSWindowSharingType.none`)
- Auto-scrolling script with the current line bright, surrounding lines dimmed
- Built-in editor for the script, scroll speed and font size
- Settings and script persist across launches
- 100% local: no network, no telemetry, no accounts

## Keyboard shortcuts

These work whenever **Menubar Prompter is the frontmost app** (e.g. just clicked it from the Dock or via ⌘-Tab). In v0.1 the bubble is intentionally a non-activating panel so it can overlay other apps' full-screen mode — the trade-off is that key events only reach the app while it's active. Use the editor sliders for fine control during a recording.

| Key       | Action                       |
| --------- | ---------------------------- |
| Space     | Play / Pause                 |
| ↑ / ↓     | Speed up / Slow down         |
| R         | Restart from the beginning   |
| E         | Open the script editor       |
| ⌘Q        | Quit                         |

## Build from source

Requires macOS 14+ and Xcode 15 / Swift 5.10+.

```bash
git clone https://github.com/pallaoro/MenubarPrompter
cd MenubarPrompter
swift run
```

Or open `Package.swift` in Xcode and hit Run.

To produce a standalone `.app` bundle (universal arm64+x86_64, ad-hoc signed):

```bash
./Scripts/build-app.sh --version 0.1.0
open "dist/Menubar Prompter.app"
```

To wrap that into a drag-to-Applications `.dmg` (requires `brew install create-dmg`):

```bash
./Scripts/build-dmg.sh --version 0.1.0
open "dist/MenubarPrompter-0.1.0.dmg"
```

## Releasing

Push a `v*` tag and the [release workflow](.github/workflows/release.yml) will build a universal `.app`, zip it, and attach it to a new GitHub release:

```bash
git tag v0.1.0
git push origin v0.1.0
```

## Roadmap

- Global keyboard shortcuts (Carbon hotkeys) so play/pause/speed work without focusing the app
- Wing height that grows to menu-bar height in full-screen mode (so the scoops sit at the same y position)
- Voice-activated scrolling (pause when you pause)
- Hover-to-pause
- Countdown before start
- Custom text color
- Menu-bar-only mode (no Dock icon)
- Notarized signed `.app` release

## License

MIT — see [LICENSE](./LICENSE).
