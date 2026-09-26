// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Reset",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "AppFoundation", targets: ["AppFoundation"]),
        .library(name: "ResetCore", targets: ["ResetCore"])
    ],
    targets: [
        .target(name: "AppFoundation"),
        .target(name: "ResetCore"),
        .testTarget(name: "ResetCoreTests", dependencies: ["ResetCore"])
    ]
)
