import SwiftUI

/// Four-point sparkle redrawn from the user's reference as a template vector.
struct NotchBrandMark: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        SparkleMark()
            .fill(color)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

private struct SparkleMark: Shape {
    func path(in rect: CGRect) -> Path {
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }
        var path = Path()
        path.move(to: point(0.46, 0.04))
        path.addQuadCurve(to: point(0.54, 0.04), control: point(0.5, -0.02))
        path.addCurve(to: point(0.94, 0.46), control1: point(0.59, 0.39), control2: point(0.6, 0.4))
        path.addQuadCurve(to: point(0.94, 0.54), control: point(1, 0.5))
        path.addCurve(to: point(0.54, 0.96), control1: point(0.6, 0.6), control2: point(0.59, 0.61))
        path.addQuadCurve(to: point(0.46, 0.96), control: point(0.5, 1.02))
        path.addCurve(to: point(0.06, 0.54), control1: point(0.41, 0.61), control2: point(0.4, 0.6))
        path.addQuadCurve(to: point(0.06, 0.46), control: point(0, 0.5))
        path.addCurve(to: point(0.46, 0.04), control1: point(0.4, 0.4), control2: point(0.41, 0.39))
        path.closeSubpath()
        return path
    }
}
