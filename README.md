# Personal Notch App

A native macOS menu-bar app inspired by Boring Notch, with Calendar, Spotify Music, Focus Timer, and a reserved Home page. Built with SwiftUI, AppKit, EventKit, and OpenNook.

## Save, open, and quit

The source and built app are already saved in this project folder. Use **File → Save All** in VS Code for any unsaved edits. Keep a backup of this folder; `.build` is a disposable build cache.

For everyday use:

1. Quit the running copy using the **sparkle icon in the menu bar → Quit**.
2. In Finder, copy **`dist/OpenNookStarter.app`** into **Applications**.
3. Double-click **OpenNookStarter** in Applications to open it. VS Code is not required.
4. To close it completely, use **sparkle icon → Quit**. Moving away from the notch only collapses it.

There is no Dock icon. Replacing the installed app is only necessary after rebuilding changes. Keep the project folder as well as the installed app so you can edit it later. Quitting resets the timer; the selected calendar and Spotify connection preference are saved locally.

## Connections

- **Calendar:** Add your class calendar to Apple Calendar, then use **Connect Calendar** and select it in the notch. macOS requests full calendar access; this app only reads events.
- **Music:** Sign into Spotify's desktop app, then click **Connect Spotify** and allow macOS Automation access.
- **Timer:** Enter minutes (`25`) or minutes:seconds (`25:30`), then press Return, Set, or Start. Pause before editing the duration.

Compact live mode follows the selected page: Music shows artwork/bars while playing; Timer shows its running countdown. Home and Calendar remain quiet. Music bars are decorative, not audio measurements. Home widgets, the Spotify queue, and timer alerts are unfinished.

## Develop and rebuild

Requires macOS 15+, Swift 5.9+, and compatible full Xcode. In a terminal:

```sh
cd "/Users/njm2/Documents/hello world/week 8/personalized OpenNook notch app"
./Scripts/package-app.sh debug
open dist/OpenNookStarter.app
```

Quit the app before rebuilding. For Release, use `./Scripts/package-app.sh release`. Copy the rebuilt app to Applications to update the installed version. Use the bundled app for permission testing.

Checks: `./Scripts/check-models.sh` and `./Scripts/check-artwork-palette.sh`. Debug build, packaging, signature, and logic checks passed; the latest visual and account interactions still need manual verification. See [PROCESS.md](PROCESS.md).

## Files and credits

- `Sources/OpenNookStarter/`: screens, calendar/Spotify connections, timer, and styles.
- `App/Info.plist`, `Scripts/`, `Tests/`: app metadata, packaging, and checks.
- `Vendor/opennook/`: local OpenNook 0.4.0 subset; [modifications](Vendor/opennook/LOCAL_CHANGES.md).
- `docs/screenshots/`: references and labeled fixture previews; runtime comparisons are still needed.

[OpenNook](https://github.com/twinkling-reality/opennook) supplies the window/hover framework (Apache-2.0; NookSurface is MIT). Calendar, player, and timer layouts adapt its [ShowcaseNook examples](https://github.com/twinkling-reality/opennook/tree/2b50b5c3a99df8914e25e199d29bf7aa505f7a59/Examples/ShowcaseNook), copyright 2026 Glendon Chin. [Boring Notch](https://theboring.name/) is an interaction reference. Apple documentation: [SwiftUI](https://developer.apple.com/documentation/swiftui), [AppKit](https://developer.apple.com/documentation/appkit), [EventKit](https://developer.apple.com/documentation/eventkit). Spotify integration uses its installed scripting dictionary, not a third-party SDK.

Development is paused as of November 9, 2026. [Earlier detailed README](docs/archive/README-2026-11-09.md).
