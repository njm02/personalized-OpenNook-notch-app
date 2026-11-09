# Local OpenNook subset

Source: https://github.com/twinkling-reality/opennook, version 0.4.0,
revision `db42d19f0636bd95115f25c2ca0d2cb75d8f9b75`.

Copied modules: NookApp, NookKit, NookSurface. The local manifest includes only
these modules. Upstream license and notice files are retained.

Local modifications (November 8, 2026):

- NookStyle.swift: added opt-in `compactMatchesHardwareNotch`, default false.
- Internal/NookView.swift: when enabled in notch layout, suppress compact slots
  including their insets and remove the compact top-corner ears/padding. The
  compact width comes from OpenNook's existing NSScreen notch measurement.
- Floating layout and expanded layout retain upstream sizing. Window management,
  screen changes, hover handling, and animation remain upstream implementations.

EmptyView slots alone leave the upstream minimum width of notch width + 12
points and slot padding. This option avoids editing SwiftPM's disposable checkout
and avoids hardcoding a width for one MacBook model.

Review these two source changes when upgrading upstream. Hardware alignment and
hover regression checks require manual verification on the target display.


## Playback live mode extension

- Nook.swift adds published `compactShowsContent` (false by default).
- NookView.swift respects that flag when applying hardware-width compact styling,
  and zeroes the horizontal offset in the idle hardware-width state.
- NookSurfaceDriving.swift exposes the flag to the coordinator.
- AppCoordinator.swift adds `setCompactContentVisible(_:)` to animate between
  idle/native width and live side slots without replacing hover/window machinery.

The selected page and its playback/timer state drive this flag. Artwork and equalizer bars use the
existing compact-slot registration API. Paused/closed/disconnected Spotify restores
an empty native-width compact state. Runtime transitions require manual testing.
