import SwiftUI

/// The selected screen determines which active session appears when collapsed.
struct CompactLiveLeading: View {
    @ObservedObject var player: SpotifyStore
    @ObservedObject var timer: WidgetStore
    var body: some View {
        if timer.compactMode(musicPlaying: player.playing) == .focus {
            Image(systemName: "flame.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(width: 20, height: 20)
                .accessibilityLabel("Focus timer running")
        } else if timer.compactMode(musicPlaying: player.playing) == .music { CompactTrackArtwork(player: player) }
    }
}

struct CompactLiveTrailing: View {
    @ObservedObject var player: SpotifyStore
    @ObservedObject var timer: WidgetStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        if timer.compactMode(musicPlaying: player.playing) == .focus {
            TimelineView(.periodic(from: .now, by: reduceMotion ? 1 : 1.0 / 15)) { context in
                let left = timer.remaining(at: context.date)
                let seconds = Int(ceil(left))
                HStack(spacing: 5) {
                    ZStack {
                        Circle().stroke(.white.opacity(0.18), lineWidth: 2)
                        Circle().trim(from: 0, to: max(0, min(1, 1 - left / timer.timerDuration)))
                            .stroke(.orange, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                    }.frame(width: 12, height: 12)
                    Text(String(format: "%02d:%02d", seconds / 60, seconds % 60))
                        .font(.system(size: 12, weight: .semibold)).monospacedDigit()
                        .foregroundStyle(.orange)
                }
                .fixedSize().frame(height: 20)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Focus timer: \(seconds / 60) minutes, \(seconds % 60) seconds remaining")
            }
        } else if timer.compactMode(musicPlaying: player.playing) == .music { CompactPlaybackBars(player: player) }
    }
}
