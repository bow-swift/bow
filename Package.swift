// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Bow",
    products: [
        .library(name: "Bow",                  targets: ["Bow"]),
        .library(name: "BowOptics",            targets: ["BowOptics"]),
        .library(name: "BowRecursionSchemes",  targets: ["BowRecursionSchemes"]),
        .library(name: "BowFree",              targets: ["BowFree"]),
        .library(name: "BowGeneric",           targets: ["BowGeneric"]),
        .library(name: "BowEffects",           targets: ["BowEffects"]),
        .library(name: "BowRx",                targets: ["BowRx"]),

        .library(name: "BowLaws",              targets: ["BowLaws"]),
        .library(name: "BowOpticsLaws",        targets: ["BowOpticsLaws"]),
        .library(name: "BowEffectsLaws",       targets: ["BowEffectsLaws"]),

        .library(name: "BowGenerators",        targets: ["BowGenerators"]),
        .library(name: "BowFreeGenerators",    targets: ["BowFreeGenerators"]),
        .library(name: "BowEffectsGenerators", targets: ["BowEffectsGenerators"]),
        .library(name: "BowRxGenerators",      targets: ["BowRxGenerators"])
    ],

    dependencies: [
        .package(url: "https://github.com/typelift/SwiftCheck.git",   from: "0.12.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git",     from: "5.0.1"),
    ],

    targets: [
        // Library targets
        .target(name:"Bow",                 dependencies: []),
        .target(name:"BowOptics",           dependencies: ["Bow"]),
        .target(name:"BowRecursionSchemes", dependencies: ["Bow"]),
        .target(name:"BowFree",             dependencies: ["Bow"]),
        .target(name:"BowGeneric",          dependencies: ["Bow"]),
        .target(name:"BowEffects",          dependencies: ["Bow"]),
        .target(name:"BowRx",               dependencies: ["RxSwift", "RxCocoa", "Bow", "BowEffects"]),

        // Test targets
        .testTarget(name: "BowTests",
                    dependencies: ["Bow", "BowLaws", "SwiftCheck"]),
        .testTarget(name: "BowOpticsTests",
                    dependencies: ["Bow", "BowOptics", "BowOpticsLaws", "SwiftCheck"]),
        .testTarget(name: "BowRecursionSchemesTests",
                    dependencies: ["Bow", "BowRecursionSchemes", "BowLaws", "SwiftCheck"]),
        .testTarget(name: "BowFreeTests",
                    dependencies: ["Bow", "BowFree", "BowFreeGenerators", "BowLaws", "SwiftCheck"]),
        .testTarget(name: "BowGenericTests",
                    dependencies: ["Bow", "BowGeneric"]),
        .testTarget(name: "BowEffectsTests",
                    dependencies: ["Bow", "BowEffects", "BowEffectsLaws", "BowEffectsGenerators", "BowLaws", "SwiftCheck"]),
        .testTarget(name: "BowRxTests",
                    dependencies: ["Bow", "BowRx", "RxSwift", "RxCocoa", "BowLaws", "BowEffects", "BowEffectsLaws", "BowEffectsGenerators", "BowRxGenerators", "SwiftCheck"]),

        // Type class Laws
        .target(name:"BowLaws",
                dependencies: ["Bow", "BowGenerators", "SwiftCheck"],
                path: "Tests/BowLaws"),
        .target(name:"BowEffectsLaws",
                dependencies: ["BowEffects", "BowLaws"],
                path: "Tests/BowEffectsLaws"),
        .target(name:"BowOpticsLaws",
                dependencies: ["BowOptics", "BowLaws"],
                path: "Tests/BowOpticsLaws"),

        // Generators for Property-based Testing
        .target(name: "BowGenerators",
                dependencies: ["Bow", "SwiftCheck"],
                path: "Tests/BowGenerators"),
        .target(name: "BowFreeGenerators",
                dependencies: ["BowFree", "BowGenerators"],
                path: "Tests/BowFreeGenerators"),
        .target(name: "BowEffectsGenerators",
                dependencies: ["BowEffects", "BowGenerators"],
                path: "Tests/BowEffectsGenerators"),
        .target(name: "BowRxGenerators",
                dependencies: ["BowRx", "BowGenerators"],
                path: "Tests/BowRxGenerators"),
    ]
)
