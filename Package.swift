// swift-tools-version:5.2
import PackageDescription

extension Target {
    var asDependency: Target.Dependency {
        .target(name: name)
    }
}

// MARK: - Libraries
extension Target {
    static var libraries: [Target] {
        [
            .bow,
            .bowOptics,
            .bowRecursionSchemes,
            .bowFree,
            .bowGeneric,
            .bowEffects,
            .bowRx,
        ]
    }
    
    static var bow: Target {
        .target(name: "Bow")
    }
    
    static var bowOptics: Target {
        .target(name: "BowOptics",
                dependencies: [Target.bow.asDependency])
    }
    
    static var bowEffects: Target {
        #if os(Linux)
        return .target(name: "BowEffects",
                       dependencies: [Target.bow.asDependency],
                       exclude: ["Foundation/FileManager+iOS+Mac.swift"])
        #else
        return .target(name: "BowEffects",
                       dependencies: [Target.bow.asDependency])
        #endif
    }
    
    static var bowRecursionSchemes: Target {
        .target(name: "BowRecursionSchemes",
                dependencies: [Target.bow.asDependency])
    }
    
    static var bowFree: Target {
        .target(name: "BowFree",
                dependencies: [Target.bow.asDependency])
    }
    
    static var bowGeneric: Target {
        .target(name: "BowGeneric",
                dependencies: [Target.bow.asDependency])
    }
    
    static var bowRx: Target {
        .target(name: "BowRx",
                dependencies: [Target.bow.asDependency,
                               Target.bowEffects.asDependency,
                               .product(name: "RxSwift", package: "RxSwift"),
                               .product(name: "RxCocoa", package: "RxSwift")])
    }
}

// MARK: - Laws
extension Target {
    static var laws: [Target] {
        [
            .bowLaws,
            .bowEffectsLaws,
            .bowOpticsLaws,
        ]
    }
    
    static var bowLaws: Target {
        .target(name:"BowLaws",
                dependencies: [Target.bowGenerators.asDependency],
                path: "Tests/BowLaws")
    }
    
    static var bowEffectsLaws: Target {
        .target(name:"BowEffectsLaws",
                dependencies: [Target.bowEffects.asDependency,
                               Target.bowLaws.asDependency],
                path: "Tests/BowEffectsLaws")
    }
    
    static var bowOpticsLaws: Target {
        .target(name:"BowOpticsLaws",
                dependencies: [Target.bowOptics.asDependency,
                               Target.bowLaws.asDependency],
                path: "Tests/BowOpticsLaws")
        
    }
}

// MARK: - Generators
extension Target {
    static var generators: [Target] {
        [
            .bowGenerators,
            .bowFreeGenerators,
            .bowEffectsGenerators,
            .bowRxGenerators,
        ]
    }
    
    static var bowGenerators: Target {
        .target(name: "BowGenerators",
                dependencies: [Target.bow.asDependency,
                               .product(name: "SwiftCheck", package: "SwiftCheck")],
                path: "Tests/BowGenerators")
    }
    
    static var bowFreeGenerators: Target {
        .target(name: "BowFreeGenerators",
                dependencies: [Target.bowFree.asDependency,
                               Target.bowGenerators.asDependency],
                path: "Tests/BowFreeGenerators")
    }
    
    static var bowEffectsGenerators: Target {
        .target(name: "BowEffectsGenerators",
                dependencies: [Target.bowEffects.asDependency,
                               Target.bowGenerators.asDependency],
                path: "Tests/BowEffectsGenerators")
    }
    
    static var bowRxGenerators: Target {
        .target(name: "BowRxGenerators",
                dependencies: [Target.bowRx.asDependency,
                               Target.bowGenerators.asDependency],
                path: "Tests/BowRxGenerators")
    }
}

// MARK:  - Tests
extension Target {
    static var tests: [Target] {
        [
            .bowTests,
            .bowOpticsTests,
            .bowRecursionSchemesTests,
            .bowFreeTests,
            .bowGenericTests,
            .bowEffectsTests,
            .bowRxTests,
        ]
    }
    
    static var bowTests: Target {
        .testTarget(name: "BowTests",
                    dependencies: [Target.bowLaws.asDependency])
    }
    
    static var bowOpticsTests: Target {
        .testTarget(name: "BowOpticsTests",
                    dependencies: [Target.bowOpticsLaws.asDependency])
    }
    
    static var bowRecursionSchemesTests: Target {
        .testTarget(name: "BowRecursionSchemesTests",
                    dependencies: [Target.bowRecursionSchemes.asDependency,
                                   Target.bowLaws.asDependency])
    }
    
    static var bowFreeTests: Target {
        .testTarget(name: "BowFreeTests",
                    dependencies: [Target.bowFreeGenerators.asDependency,
                                   Target.bowLaws.asDependency])
    }
    
    static var bowGenericTests: Target {
        .testTarget(name: "BowGenericTests",
                    dependencies: [Target.bowGeneric.asDependency])
    }
    
    static var bowEffectsTests: Target {
        .testTarget(name: "BowEffectsTests",
                    dependencies: [Target.bowEffectsGenerators.asDependency,
                                   Target.bowEffectsLaws.asDependency])
    }
    
    static var bowRxTests: Target {
        .testTarget(name: "BowRxTests",
                    dependencies: [Target.bowRxGenerators.asDependency,
                                   Target.bowEffectsGenerators.asDependency,
                                   Target.bowEffectsLaws.asDependency])
    }
}


// MARK: - Package
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
        .package(url: "https://github.com/bow-swift/SwiftCheck.git", from: "0.12.1"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.1"),
    ],

    targets: [
        Target.libraries,
        Target.laws,
        Target.generators,
        Target.tests,
    ].flatMap { $0 }
)
