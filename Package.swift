// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftAsyncNetwork",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftAsyncNetwork",
            targets: ["SwiftAsyncNetwork"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftAsyncNetwork",
            dependencies: [],
            path: "Sources/Core"
        ),
        .testTarget(
            name: "SwiftAsyncNetworkTests",
            dependencies: ["SwiftAsyncNetwork"]
        )
    ]
)
