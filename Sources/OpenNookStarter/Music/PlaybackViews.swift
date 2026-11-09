import SwiftUI

struct TrackArtwork: View {
    @ObservedObject var player: SpotifyStore
    var body: some View {
        Group {
            if let image = player.artwork {
                Image(nsImage: image).resizable().scaledToFill()
            } else {
                Color.white.opacity(0.07).overlay { Image(systemName: "music.note").foregroundStyle(.secondary) }
            }
        }.clipped()
    }
}

struct PlaybackBars: View {
    var tint: Color = .white.opacity(0.85)
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { context in
            let phase = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate
            HStack(spacing: 1.6) {
                ForEach(0..<6) { index in
                    RoundedRectangle(cornerRadius: 1.3, style: .circular).fill(tint)
                        .frame(width: 2.6, height: 3 + 19 * PlaybackMotion.level(at: phase, bar: index))
                }
            }.frame(width: 24, height: 26)
        }
        .animation(.easeInOut(duration: 0.6), value: tint)
        .accessibilityLabel("Spotify is playing")
    }
}

struct CompactTrackArtwork: View {
    @ObservedObject var player: SpotifyStore
    var body: some View {
        if player.playing {
            TrackArtwork(player: player).frame(width: 20, height: 20).clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

struct CompactPlaybackBars: View {
    @ObservedObject var player: SpotifyStore
    var body: some View {
        if player.playing { PlaybackBars(tint: Color(nsColor: player.artworkTint)).scaleEffect(0.68).frame(width: 20, height: 20) }
    }
}
