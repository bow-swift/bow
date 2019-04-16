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
        .package(url: "https://github.com/typelift/SwiftCheck.git", from: "0.12.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.1"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .branch("master")),
        .package(url: "https://github.com/Thomvis/BrightFutures.git", from: "8.0.0"),
    ],
    targets: [
        .target(name: "Bow", dependencies: []),
        .testTarget(name: "BowTests", dependencies: ["Bow", "BowLaws", "SwiftCheck", "Nimble"]),
        .target(name:"BowOptics", dependencies: ["Bow"]),
        .testTarget(name: "BowOpticsTests", dependencies: ["BowOptics", "Bow", "SwiftCheck"]),
        .target(name:"BowRecursionSchemes", dependencies: ["Bow"]),
        .testTarget(name: "BowRecursionSchemesTests", dependencies: ["BowRecursionSchemes", "Bow", "BowLaws", "SwiftCheck", "Nimble"]),
        .target(name:"BowFree", dependencies: ["Bow"]),
        .testTarget(name: "BowFreeTests", dependencies: ["BowFree", "Bow", "BowLaws", "SwiftCheck", "Nimble"]),
        .target(name:"BowGeneric", dependencies: ["Bow"]),
        .testTarget(name: "BowGenericTests", dependencies: ["BowGeneric", "Bow"]),
        .target(name:"BowEffects", dependencies: ["Bow"]),
        .testTarget(name: "BowEffectsTests", dependencies: ["BowEffects", "BowEffectsLaws", "Bow", "BowLaws", "SwiftCheck", "Nimble"]),
        .target(name:"BowResult", dependencies: ["Bow"]),
        .testTarget(name: "BowResultTests", dependencies: ["BowResult", "Bow", "SwiftCheck"]),
        .target(name:"BowRx", dependencies: ["RxSwift", "RxCocoa", "Bow", "BowEffects"]),
        .testTarget(name: "BowRxTests", dependencies: ["BowRx", "RxSwift", "RxCocoa", "Bow", "BowLaws", "BowEffects", "BowEffectsLaws", "SwiftCheck", "Nimble"]),
        .target(name:"BowBrightFutures", dependencies: ["BrightFutures", "Bow", "BowEffects", "BowResult"]),
        .testTarget(name: "BowBrightFuturesTests", dependencies: ["BowBrightFutures", "BrightFutures", "Bow",  "BowLaws", "BowEffects", "BowEffectsLaws", "BowResult", "SwiftCheck", "Nimble"]),
        .testTarget(name:"BowLaws", dependencies: ["Bow", "SwiftCheck", "Nimble"]),
        .testTarget(name:"BowEffectsLaws", dependencies: ["Bow", "BowEffects", "SwiftCheck", "Nimble"]),
    ]
)
