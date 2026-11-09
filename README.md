# Personal Notch App

A native macOS menu-bar utility that turns the MacBook notch into a compact calendar, Spotify player, and focus timer. Built with SwiftUI and [OpenNook](https://opennook.dev/), with interaction inspiration from [Boring Notch](https://theboring.name/).

**Status:** Development prototype. Build and logic checks pass; the latest visual changes and account interactions still need manual verification. Design intentions, decisions, and testing evidence are recorded in [PROCESS.md](PROCESS.md).

## Features

- **Calendar:** Month grid, selected-day agenda, calendar selection, and distinct event markers. Reads calendars available through Apple Calendar, including synced Google calendars.
- **Music:** Spotify desktop artwork, playback controls, seeking, and artwork-colored animated bars.
- **Focus timer:** Typed duration, pause/resume, reset, and a five-minute extension.
- **Compact live mode:** Music artwork/bars or timer countdown based on the selected screen.
- **Consistent layout:** Icon navigation, a quiet idle notch, and a custom sparkle menu-bar mark. Home is reserved for future widgets.

## Requirements

- macOS 15 or later; a notched MacBook is the intended display.
- Compatible full Xcode with Swift 5.9 or later selected as the developer toolchain.
- Spotify desktop app for music features; an account in Apple Calendar for calendar features.

OpenNook is vendored locally. No additional package installation is required.

## Build and run

Clone or download this repository, open its root folder in a terminal, then run:

```sh
./Scripts/package-app.sh debug
open dist/OpenNookStarter.app
```

Use the bundled app for calendar and Spotify permissions. `swift build` checks compilation, but `swift run` does not supply the bundle's permission descriptions.

For a Release build:

```sh
./Scripts/package-app.sh release
```

Both commands produce an ad-hoc signed `dist/OpenNookStarter.app`. Quit the running copy before rebuilding.

## Install and use

Copy `dist/OpenNookStarter.app` into **Applications** and double-click it. The app runs independently of VS Code and has no Dock icon. Use **sparkle menu-bar icon → Quit** to close it; moving away from the notch only collapses it.

- **Calendar:** Click Connect Calendar, approve access, and select a calendar. macOS requests full calendar access; the app only reads events.
- **Spotify:** Sign into the desktop app, click Connect Spotify, and approve Automation access.
- **Timer:** Enter `25` for minutes or `25:30` for minutes:seconds, then press Return, Set, or Start. Pause before editing.

Installed copies do not update automatically. Rebuild, quit, replace the app in Applications, and reopen it. Keep the source folder for future edits.

## Checks and limitations

```sh
./Scripts/check-models.sh
./Scripts/check-artwork-palette.sh
```

Checks cover calendar calculations, timer/input behavior, live-mode selection, motion continuity, and artwork tint. Runtime verification is tracked in [PROCESS.md](PROCESS.md).

Home widgets, Spotify queue/remote-device control, timer alerts, and general widget customization are unfinished. Timer state resets on quit. Music bars indicate playback status, not audio levels. Calendar refresh relies on macOS synchronization.

## Project structure

| Path | Purpose |
| --- | --- |
| `Sources/OpenNookStarter/` | Screens, calendar/Spotify connections, timer, and styles |
| `App/Info.plist` | Bundle identity and permission descriptions |
| `Scripts/` and `Tests/` | Packaging and logic checks |
| `Vendor/opennook/` | OpenNook 0.4.0 subset, licenses, and [local changes](Vendor/opennook/LOCAL_CHANGES.md) |
| `docs/screenshots/` | Reference images and labeled synthetic previews |

## Credits

[OpenNook](https://github.com/twinkling-reality/opennook) provides the notch framework under Apache-2.0, with MIT-licensed NookSurface. Calendar, player, and timer layouts adapt its [ShowcaseNook examples](https://github.com/twinkling-reality/opennook/tree/2b50b5c3a99df8914e25e199d29bf7aa505f7a59/Examples/ShowcaseNook), copyright 2026 Glendon Chin. Original notices are retained in the vendored source and packaged app.

Native APIs: Apple [SwiftUI](https://developer.apple.com/documentation/swiftui), [AppKit](https://developer.apple.com/documentation/appkit), and [EventKit](https://developer.apple.com/documentation/eventkit). Spotify integration uses its installed scripting dictionary. AI contributions and supplied visual references are credited in [PROCESS.md](PROCESS.md).
