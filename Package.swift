// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Bow",
    products: [
        .library(name: "Bow", targets: ["Bow"]),
        .library(name: "BowOptics", targets: ["BowOptics"]),
        .library(name: "BowRecursionSchemes", targets: ["BowRecursionSchemes"]),
        .library(name: "BowFree", targets: ["BowFree"]),
        .library(name: "BowGeneric", targets: ["BowGeneric"]),
        .library(name: "BowEffects", targets: ["BowEffects"]),
        .library(name: "BowResult", targets: ["BowResult"]),
        .library(name: "BowRx", targets: ["BowRx"]),
        .library(name: "BowBrightFutures", targets: ["BowBrightFutures"]),
    ],
    dependencies: [
        .package(url: "https://github.com/typelift/SwiftCheck", from: "0.9.1"),
        .package(url: "https://github.com/Quick/Nimble", from: "7.0.2"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "4.4.0"),
        .package(url: "https://github.com/antitypical/Result", from: "4.0.0"),
        .package(url: "https://github.com/Thomvis/BrightFutures", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "Bow",
            dependencies: ["RxSwift", "RxCocoa", "Result", "BrightFutures"],
            path: "Sources"),
        .testTarget(
            name: "BowTests",
            dependencies: ["Bow", "SwiftCheck", "Nimble"],
            path: "Tests")
    ]
)
