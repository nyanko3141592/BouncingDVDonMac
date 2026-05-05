// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DVDBouncer",
    platforms: [
        .macOS(.v14),
    ],
    targets: [
        .executableTarget(
            name: "DVDBouncer"
        ),
    ]
)
