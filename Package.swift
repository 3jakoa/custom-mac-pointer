// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CustomMacPointer",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "CustomMacPointer",
            resources: [
                .copy("Resources/Bureks")
            ]
        )
    ]
)
