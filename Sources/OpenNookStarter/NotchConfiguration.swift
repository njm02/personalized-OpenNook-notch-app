import NookApp
import SwiftUI

enum NotchConfiguration {
    static func make() -> NookConfiguration {
        var configuration = NookConfiguration()
        configuration.branding.mark = { size, color in
            AnyView(NotchBrandMark(size: size, color: color))
        }
        configuration.setHome { ExpandedNotchView(store: WidgetStore.shared) }
        configuration.expandedWidth = 560
        // A non-spring conversion keeps the bottom edge from overshooting its final height.
        configuration.transitions = NookTransitionConfiguration(
            conversionAnimation: .easeInOut(duration: 0.35),
            animationDuration: 0.4
        )
        configuration.chromeBehavior.backdrop = { _, _, _ in .solid(.black) }
        configuration.topBar.showsTopBar = false
        configuration.setCompactLeading { CompactLiveLeading(player: SpotifyStore.shared, timer: WidgetStore.shared) }
        configuration.setCompactTrailing { CompactLiveTrailing(player: SpotifyStore.shared, timer: WidgetStore.shared) }
        configuration.onReady = { coordinator in
            let player = SpotifyStore.shared
            let updateLiveMode: (Bool) -> Void = { [weak coordinator] _ in
                coordinator?.setCompactContentVisible(WidgetStore.shared.compactMode(musicPlaying: SpotifyStore.shared.playing) != .idle)
            }
            player.liveModeChanged = updateLiveMode
            WidgetStore.shared.liveModeChanged = updateLiveMode
            updateLiveMode(false)
            player.resumeConnection()
        }
        // Match OpenNook 0.4.0 AppCoordinator's expanded corner defaults.
        var style = NookStyle(topCornerRadius: 19, bottomCornerRadius: 24)
        style.compactMatchesHardwareNotch = true
        configuration.style = style
        configuration.chromeBehavior.showsLaunchShimmer = false
        return configuration
    }
}
