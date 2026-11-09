// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "OpenNookStarter",
    platforms: [.macOS("15.0")],
    products: [
        .executable(name: "OpenNookStarter", targets: ["OpenNookStarter"])
    ],
    dependencies: [
        .package(path: "Vendor/opennook")
    ],
    targets: [
        .executableTarget(
            name: "OpenNookStarter",
            dependencies: [
                .product(name: "NookApp", package: "opennook")
            ],
            path: "Sources/OpenNookStarter"
        )
    ]
)
