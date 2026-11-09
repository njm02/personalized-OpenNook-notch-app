import SwiftUI

/// Monochrome Spotify identifier for the music destination.
struct SpotifyMark: View {
    var body: some View {
        SpotifyGlyph().fill(style: FillStyle(eoFill: true))
            .aspectRatio(1, contentMode: .fit)
            .accessibilityHidden(true)
    }
}

private struct SpotifyGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let size = min(rect.width, rect.height)
        let x = rect.midX - size / 2
        let y = rect.midY - size / 2
        func point(_ px: CGFloat, _ py: CGFloat) -> CGPoint {
            CGPoint(x: x + px * size, y: y + py * size)
        }
        var result = Path(ellipseIn: CGRect(x: x, y: y, width: size, height: size))
        for (startY, endY, controlY, width) in [
            (0.36, 0.40, 0.23, 0.09),
            (0.51, 0.55, 0.40, 0.075),
            (0.66, 0.69, 0.57, 0.065)
        ] {
            var wave = Path()
            wave.move(to: point(0.24, startY))
            wave.addQuadCurve(to: point(0.77, endY), control: point(0.52, controlY))
            result.addPath(wave.strokedPath(StrokeStyle(lineWidth: size * width, lineCap: .round)))
        }
        return result
    }
}
