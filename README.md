# Menubar Prompter

A minimal open-source teleprompter for macOS. Sits as a discreet floating bubble right under your menu bar — directly below the camera notch — so you can keep eye contact while you read.

## Features

- Borderless bubble window auto-positioned under the menu bar
- Always-on-top, draggable from anywhere, freely resizable
- Auto-scrolling script with the current line highlighted and surrounding lines dimmed
- Hidden from screen sharing and screen recording (`NSWindowSharingType.none`)
- Built-in script editor with speed and font-size sliders
- Script and settings persist across launches
- 100% local: no network, no telemetry, no accounts

## Keyboard shortcuts

These work whenever the prompter window is focused.

| Key       | Action                          |
| --------- | ------------------------------- |
| Space     | Play / Pause                    |
| ↑ / ↓     | Speed up / Slow down            |
| R         | Restart from the beginning      |
| E         | Open the script editor          |
| ⌘Q        | Quit                            |

Drag the bubble from anywhere on its surface. Resize from any edge.

## Build & run

Requires macOS 14+ and Xcode 15 / Swift 5.10+.

```bash
git clone https://github.com/<you>/MenubarPrompter
cd MenubarPrompter
swift run
```

Or open `Package.swift` in Xcode and hit Run.

## Status

Early MVP. Roadmap ideas (none committed yet):

- Voice-activated scrolling (pause when you pause)
- Hover-to-pause
- Countdown before start
- Custom text color
- Menu-bar-only mode (no Dock icon)
- Notarized signed `.app` release

## License

MIT — see [LICENSE](./LICENSE).
