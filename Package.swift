// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Bow",
    products: [
        .library(
            name: "Bow",
            targets: ["Bow"]),
    ],
    dependencies: [
        .package(url: "https://github.com/typelift/SwiftCheck", from: "0.9.1"),
        .package(url: "https://github.com/Quick/Nimble", from: "7.0.2")
    ],
    targets: [
        .target(
            name: "Bow",
            path: "Sources"),
        .testTarget(
            name: "BowTests",
            dependencies: ["Bow", "SwiftCheck", "Nimble"],
            path: "Tests")
    ]
)
