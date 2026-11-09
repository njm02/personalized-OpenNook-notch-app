import AppKit

@main struct ArtworkPaletteChecks {
    @MainActor static func main() {
        let samples: [([UInt8], CGFloat?)] = [
            ([255, 0, 0, 255], 0), ([0, 0, 255, 255], 2.0 / 3.0),
            ([0, 0, 0, 255], nil), ([128, 128, 128, 255], nil)
        ]
        for (rgba, expectedHue) in samples {
            let data = Data((0..<16).flatMap { _ in rgba })
            let provider = CGDataProvider(data: data as CFData)!
            let cgImage = CGImage(width: 4, height: 4, bitsPerComponent: 8, bitsPerPixel: 32,
                bytesPerRow: 16, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
            let image = NSImage(cgImage: cgImage, size: NSSize(width: 4, height: 4))
            let tint = ArtworkPalette.tint(from: image).usingColorSpace(.deviceRGB)!
            var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0
            tint.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
            assert(brightness >= 0.69)
            if let expectedHue {
                assert(abs(hue - expectedHue) < 0.06 && saturation > 0.25)
            } else { assert(saturation < 0.05) }
        }
        print("PASS: artwork hue retained for red/blue; grayscale and black stay neutral and legible")
    }
}
