import AppKit

/// A small CPU thumbnail sample per artwork change, never per animation frame.
@MainActor
enum ArtworkPalette {
    static func tint(from image: NSImage) -> NSColor {
        let fallback = NSColor(calibratedRed: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return fallback }
        let side = 16
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        return pixels.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(data: buffer.baseAddress, width: side, height: side,
                bitsPerComponent: 8, bytesPerRow: side * 4, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue) else { return fallback }
            context.interpolationQuality = .low
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: side, height: side))
            let bytes = buffer.bindMemory(to: UInt8.self)
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, count: CGFloat = 0
            for index in stride(from: 0, to: bytes.count, by: 4) {
                let alpha = CGFloat(bytes[index + 3])
                guard alpha >= 128 else { continue }
                red += CGFloat(bytes[index]) / alpha
                green += CGFloat(bytes[index + 1]) / alpha
                blue += CGFloat(bytes[index + 2]) / alpha
                count += 1
            }
            guard count > 0 else { return fallback }
            let color = NSColor(calibratedRed: red / count, green: green / count, blue: blue / count, alpha: 1)
            var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
            // Keep grayscale artwork neutral and dark covers legible against the notch.
            guard saturation >= 0.12 else { return fallback }
            return NSColor(calibratedHue: hue, saturation: min(0.8, max(0.3, saturation)),
                           brightness: min(0.95, max(0.7, brightness)), alpha: 1)
        }
    }
}
