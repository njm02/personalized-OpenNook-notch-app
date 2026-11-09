import Foundation

/// Smoothly interpolates independent pseudo-random targets instead of repeating a wave.
enum PlaybackMotion {
    static func level(at time: TimeInterval, bar: Int) -> Double {
        let period = (0.38 + Double(bar) * 0.07) / 1.2
        let position = time / period
        let step = Int64(floor(position))
        let t = position - floor(position)
        let blend = t * t * t * (t * (t * 6 - 15) + 10)
        let from = target(step, bar: bar)
        return from + (target(step + 1, bar: bar) - from) * blend
    }

    private static func target(_ step: Int64, bar: Int) -> Double {
        var seed = UInt64(bitPattern: step) &+ (UInt64(bar + 1) &* 0x9e3779b97f4a7c15)
        seed = (seed ^ (seed >> 30)) &* 0xbf58476d1ce4e5b9
        seed = (seed ^ (seed >> 27)) &* 0x94d049bb133111eb
        seed ^= seed >> 31
        return 0.1 + 0.9 * Double(seed >> 11) / 9_007_199_254_740_992
    }
}
