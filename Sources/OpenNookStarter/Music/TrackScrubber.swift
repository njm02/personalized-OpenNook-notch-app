import SwiftUI

/// A thin track with a hover-only handle and a larger invisible interaction area.
struct TrackScrubber: View {
    let position: Double
    let duration: Double
    let onSeek: (Double) -> Void
    @State private var hovered = false
    @State private var draft: Double?

    private var value: Double { max(0, min(duration, draft ?? position)) }

    var body: some View {
        HStack(spacing: 9) {
            Text(MusicWidget.time(value)).frame(minWidth: 26, alignment: .trailing)
            GeometryReader { geometry in
                let fraction = value / max(1, duration)
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.28)).frame(height: 4)
                    Capsule().fill(.white).frame(width: geometry.size.width * fraction, height: 4)
                    if hovered || draft != nil {
                        Circle().fill(.white).frame(width: 9, height: 9)
                            .offset(x: max(0, min(geometry.size.width - 9, geometry.size.width * fraction - 4.5)))
                    }
                }
                .frame(height: 20)
                .contentShape(Rectangle())
                .onHover { hovered = $0 }
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { draft = seekValue(at: $0.location.x, width: geometry.size.width) }
                    .onEnded {
                        onSeek(seekValue(at: $0.location.x, width: geometry.size.width))
                        draft = nil
                    })
            }.frame(height: 20)
            Text(MusicWidget.time(duration)).frame(minWidth: 26, alignment: .leading)
        }
        .font(.system(size: 9)).monospacedDigit().foregroundStyle(.secondary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Spotify track position")
        .accessibilityValue("\(MusicWidget.time(value)) of \(MusicWidget.time(duration))")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: onSeek(min(duration, value + 5))
            case .decrement: onSeek(max(0, value - 5))
            @unknown default: break
            }
        }
        .focusable()
        .onMoveCommand { direction in
            if direction == .left { onSeek(max(0, value - 5)) }
            if direction == .right { onSeek(min(duration, value + 5)) }
        }
    }

    private func seekValue(at x: CGFloat, width: CGFloat) -> Double {
        max(0, min(1, x / max(1, width))) * duration
    }
}
