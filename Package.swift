// swift-tools-version:5.0
import PackageDescription

extension Target {
    static var BowEffects: Target {
        #if os(Linux)
        return .target(name:"BowEffects", dependencies: ["Bow"], exclude: ["Foundation/FileManager+iOS+Mac.swift"])
        #else
        return .target(name:"BowEffects", dependencies: ["Bow"])
        #endif
    }
}


let package = Package(
    name: "Bow",
    products: [
        .library(name: "Bow",                  targets: ["Bow"]),
        .library(name: "BowOptics",            targets: ["BowOptics"]),
        .library(name: "BowRecursionSchemes",  targets: ["BowRecursionSchemes"]),
        .library(name: "BowFree",              targets: ["BowFree"]),
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
        .package(url: "https://github.com/bow-swift/SwiftCheck.git",   from: "0.12.1"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git",     from: "5.0.1"),
    ],

    targets: [
        // Library targets
        .target(name:"Bow",                 dependencies: []),
        .target(name:"BowOptics",           dependencies: ["Bow"]),
        .target(name:"BowRecursionSchemes", dependencies: ["Bow"]),
        .target(name:"BowFree",             dependencies: ["Bow"]),
        .target(name:"BowGeneric",          dependencies: ["Bow"]),
        .BowEffects,
        .target(name:"BowRx",               dependencies: ["RxSwift", "RxCocoa", "Bow", "BowEffects"]),

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
        
        // Test targets
        .testTarget(name: "BowTests",
                    dependencies: ["BowLaws"]),
        .testTarget(name: "BowOpticsTests",
                    dependencies: ["BowOpticsLaws"]),
        .testTarget(name: "BowRecursionSchemesTests",
                    dependencies: ["BowRecursionSchemes", "BowLaws"]),
        .testTarget(name: "BowFreeTests",
                    dependencies: ["BowFreeGenerators", "BowLaws"]),
        .testTarget(name: "BowGenericTests",
                    dependencies: ["BowGeneric"]),
        .testTarget(name: "BowEffectsTests",
                    dependencies: ["BowEffectsGenerators", "BowEffectsLaws"]),
        .testTarget(name: "BowRxTests",
                    dependencies: ["BowRxGenerators", "BowEffectsGenerators", "BowEffectsLaws"]),
    ]
)
