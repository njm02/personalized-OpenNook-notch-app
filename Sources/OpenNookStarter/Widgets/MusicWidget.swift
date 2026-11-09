// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Glendon Chin (OpenNook reference layouts)
// Local modifications: personal notch app integration and real-data behavior.
// Layout adapted from OpenNook ShowcaseNook PlayerScene.swift (Apache-2.0).
import AppKit
import SwiftUI

struct MusicWidget: View {
    @ObservedObject var player: SpotifyStore
    private let artworkSize: CGFloat = 124
    var body: some View {
        Group {
            if player.connected {
                HStack(alignment: .top, spacing: 26) {
                    TrackArtwork(player: player).frame(width: artworkSize, height: artworkSize)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(alignment: .top, spacing: 12) {
                                Text(player.title).font(.system(size: 16, weight: .semibold)).lineLimit(1)
                                Spacer(minLength: 0)
                                if player.playing { PlaybackBars(tint: Color(nsColor: player.artworkTint)) }
                            }
                            Text(player.artist).font(.system(size: 12, weight: .medium)).foregroundStyle(.secondary).lineLimit(1)
                            Text(player.album).font(.system(size: 10)).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Spacer(minLength: 6)
                        TrackScrubber(position: player.position, duration: player.duration, onSeek: player.seek)
                        transportControls.padding(.top, 6)
                    }.frame(maxWidth: .infinity).frame(height: artworkSize)
                }
                .padding(.horizontal, 10)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Listen with Spotify", systemImage: "music.note").font(.system(size: 18, weight: .semibold))
                    Text(player.message ?? "Connect the Spotify app on this Mac to show your music and enable live mode.")
                        .font(.system(size: 12)).foregroundStyle(.secondary)
                    HStack {
                        Button("Connect Spotify") { player.connect() }.buttonStyle(WidgetButtonStyle())
                        Button("Open Spotify") { openSpotify() }.buttonStyle(WidgetButtonStyle())
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
        }
    }

    private var transportControls: some View {
        HStack(spacing: 24) {
            transport("Shuffle", "shuffle", active: player.shuffled) { player.command("set shuffling to not shuffling") }
            transport("Previous", "backward.fill") { player.command("previous track") }
            Button { player.command("playpause") } label: {
                Image(systemName: player.playing ? "pause.fill" : "play.fill")
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(.black)
                    .frame(width: 32, height: 32).background(.white, in: Circle())
            }.buttonStyle(.plain).accessibilityLabel(player.playing ? "Pause Spotify" : "Play Spotify")
            transport("Next", "forward.fill") { player.command("next track") }
            transport("Repeat", "repeat", active: player.repeated) { player.command("set repeating to not repeating") }
        }.frame(maxWidth: .infinity)
    }

    private func transport(_ title: String, _ symbol: String, active: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(systemName: symbol).font(.system(size: 12)).foregroundStyle(active ? .white : .gray).frame(width: 20, height: 24) }
            .buttonStyle(.plain).help(title).accessibilityLabel(title)
    }
    private func openSpotify() { NSWorkspace.shared.open(URL(string: "spotify:")!) }
    static func time(_ value: Double) -> String { let n = Int(max(0, value)); return String(format: "%d:%02d", n / 60, n % 60) }
}
