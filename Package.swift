// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CustomMacPointer",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/AmoreComputer/AmoreKit", from: "0.1.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.9.0")
    ],
    targets: [
        .executableTarget(
            name: "CustomMacPointer",
            dependencies: [
                .product(name: "AmoreLicensing", package: "AmoreKit"),
                .product(name: "Sparkle", package: "Sparkle")
            ],
            resources: [
                .copy("Resources/Bureks")
            ]
        )
    ]
)
