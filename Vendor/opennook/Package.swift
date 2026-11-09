// swift-tools-version: 5.9
// Local subset of OpenNook 0.4.0. See LOCAL_CHANGES.md and LICENSE.
import PackageDescription
let package = Package(
    name: "Nook",
    platforms: [.macOS("15.0")],
    products: [.library(name: "NookApp", targets: ["NookApp"])],
    targets: [
        .target(name: "NookSurface", swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]),
        .target(name: "NookKit", dependencies: ["NookSurface"], swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]),
        .target(name: "NookApp", dependencies: ["NookKit"], swiftSettings: [.enableUpcomingFeature("StrictConcurrency")])
    ]
)
