# Process Journal

Development: November 8–9, 2026. Paused at my request on November 9. This condensed journal preserves intention, evidence, decisions, and credits; the [full earlier journal](docs/archive/PROCESS-2026-11-09.md) keeps the detailed history.

## A. My goal — intention

**What I wanted to improve:** Make the notch more useful for my class schedule, music, and focus sessions, with control over which information appears and how it looks.

**What I changed:** I chose separate Calendar, Music, and Focus Timer screens, a smaller consistent panel, icon navigation, and live mode based on the selected screen. I requested a month/day calendar, clearer event colors, a Spotify-style player, and typed timer durations.

**What I kept the same:** The quiet black notch, hover-to-expand interaction, and minimal feel that I liked in Boring Notch. I kept OpenNook's native window and hover machinery as the foundation. These choices support quick access without adding a permanent desktop panel.

My intention is broader than the current result. The app now has those screens, calendar/Spotify integration code, a timer, and compact live modes. General widget customization and Home content remain unfinished.

## B. What I checked — evidence

| Check | Recorded result |
| --- | --- |
| Initial build with Command Line Tools | Failed: cache permissions and Swift/SDK/macro issues. Builds later passed with full Xcode. |
| App launch and hover expansion/collapse | Passed according to my reports. I also approved the refined idle notch appearance. |
| Debug build, packaging, plist, and signature checks | Passed for the developed app; latest layout build and signature passed. |
| Date, timer, input validation, motion, and live-mode logic | Passed retained checks in `Tests/ModelChecks.swift`. Includes all 16 page/activity combinations. |
| Artwork-color fixtures | Initial fixture/color-space errors were corrected; final red/blue/gray/black checks passed. |
| Spotify script syntax | Compiled against the installed Spotify dictionary. This alone does not verify playback access. |
| Synthetic screen previews | Earlier previews had equal bounds. They use fixture data; calendar scroll rows were not captured. They predate later layout changes. |

### Before and after

| Original state / my observation | Change | Observed result |
| --- | --- | --- |
| Collapsed notch was too wide and showed icons. | Removed idle icons and extra width. | I said “looks good” after the change. Exact pixel width was not measured. |
| Music felt cramped; bars looked repetitive; text/controls extended beyond artwork bounds. | Revised spacing, randomized artwork-tinted bars, and matching artwork/column heights. | Build passed; final appearance **Needs manual verification**. |
| Two classes shared the same event marker color. | Different marker hues within the selected day's agenda. | Build passed; revised colors **Need manual verification**. |

**Still needs manual verification:** latest readability/edge spacing, calendar event accuracy and scrolling, Spotify controls/artwork/seek, timer typing/focus, and live-mode transitions during hover and page changes. Release installation, external displays, and accessibility interactions have not been fully tested.

Screenshots are in `docs/screenshots/`. Supplied OpenNook screenshots are **references**; `fixture-*` files are **synthetic previews**, not evidence of my running app. Capture real before/after screens and record observations before claiming visual success.

### AI prompt record — November 8, 2026

Task: Start the minimum viable project before adding widgets.

Prompt excerpt (verbatim):

> Begin by inspecting OpenNook and creating the minimum viable project. Explain the setup and show me how to launch the initial working version before adding the full widget interface.

Codex's first response (verbatim):

> I’ll read the pasted project brief and inspect the current app files, then work through the requested build in this workspace.

## C. My decisions and credits

**My decisions:** Calendar/Music/Timer as separate screens; icon navigation and text-only titles; a compact, consistent panel; month grid beside daily events; a Spotify-style player; custom timer input instead of presets; solid flame; the supplied sparkle logo; and live mode following the selected page. I requested smaller side margins and music content bounded by the artwork's height. These requests do not imply approval of every later implementation detail.

**Codex contributions:** Generated Swift code, architecture and data-connection work, debugging, tests, packaging, and documentation. Codex chose exact dimensions, color calculations, animation algorithms, input limits, and some spacing. These choices still need my review. The local OpenNook modifications retain its hover/window machinery but create an upstream-update maintenance responsibility.

**Project evidence:** [App code](Sources/OpenNookStarter/), [checks](Tests/), and [reference images and labeled previews](docs/screenshots/). Classmate feedback has not been recorded yet.

**External sources:**

- [OpenNook framework](https://github.com/twinkling-reality/opennook) and [documentation](https://opennook.dev/): Apache-2.0, with MIT-licensed NookSurface. [Local changes](Vendor/opennook/LOCAL_CHANGES.md) and original notices are in `Vendor/opennook/`.
- [ShowcaseNook layouts](https://github.com/twinkling-reality/opennook/tree/2b50b5c3a99df8914e25e199d29bf7aa505f7a59/Examples/ShowcaseNook): AgendaScene, PlayerScene, TimerScene; copyright 2026 Glendon Chin, Apache-2.0. Layouts were adapted; sample songs/events were not imported.
- [Boring Notch](https://theboring.name/): design reference; its code/assets are not used.
- Apple [SwiftUI](https://developer.apple.com/documentation/swiftui), [AppKit](https://developer.apple.com/documentation/appkit), and [EventKit](https://developer.apple.com/documentation/eventkit): native UI and calendar APIs.
- Spotify's installed `Spotify.sdef`: desktop integration contract. The Spotify tab mark is a Codex-drawn vector identifier.
- Sparkle logo and screen references: supplied by me. Original artwork creator/license was not provided; authorship is not assumed.

## D. My next question — reflection

| Phase | Reflection and critique question |
| --- | --- |
| Foundation | The original toolchain failed; full Xcode enabled builds. Launch/hover and idle appearance received my approval. Further display checks remain. **Can people discover a quiet notch without extra icons?** |
| Widgets and refinement | I tried a combined widget layout, then requested separate screens and revised the crowded player and repetitive motion. Latest visual/account checks remain. **Can a classmate quickly find the next class, current song, or time remaining?** |

**Unfinished:** Home is still a placeholder because I deferred it while refining the main screens. General widget customization is not implemented. Spotify desktop scripting supplies playback controls but does not expose its queue, so queue display remains unfinished.

Next session: test the current bundle, record actual observations and screenshots, fix readability or interaction issues, then design Home. The November 9 documentation edits clarify the assignment record; they add no new runtime evidence.

