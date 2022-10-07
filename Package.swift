// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Bow",

    products: [
        .core,
        .optics,
        .effects,
        .rx,
        .free,
        .generic,
        .recursionSchemes,

        .laws,
        .opticsLaws,
        .effectsLaws,

        .generators,
        .freeGenerators,
        .effectsGenerators,
        .rxGenerators,
    ],

    dependencies: [
        .package(url: "https://github.com/bow-swift/SwiftCheck.git", from: "0.12.1"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0"),
    ],

    targets: [
        // Main targets
        .bow,
        .bowEffects,
        .bowRx,
        .bowOptics,
        .bowRecursionSchemes,
        .bowFree,
        .bowGeneric,
        
        // Laws
        .bowLaws,
        .bowEffectsLaws,
        .bowOpticsLaws,
        
        // Generators
        .bowGenerators,
        .bowEffectsGenerators,
        .bowRxGenerators,
        .bowFreeGenerators,
        
        // Test targets
        .bowTests,
        .bowOpticsTests,
        .bowEffectsTests,
        .bowRxTests,
        .bowRecursionSchemesTests,
        .bowFreeTests,
        .bowGenericTests,
    ]
)

enum Module {
    static let core = "Bow"
    static let optics = "BowOptics"
    static let effects = "BowEffects"
    static let rx = "BowRx"
    static let recursionSchemes = "BowRecursionSchemes"
    static let free = "BowFree"
    static let generic = "BowGeneric"
    
    static let laws = "BowLaws"
    static let effectsLaws = "BowEffectsLaws"
    static let opticsLaws = "BowOpticsLaws"
    
    static let generators = "BowGenerators"
    static let effectsGenerators = "BowEffectsGenerators"
    static let rxGenerators = "BowRxGenerators"
    static let freeGenerators = "BowFreeGenerators"
}

enum Test {
    static let core = "BowTests"
    static let effects = "BowEffectsTests"
    static let rx = "BowRxTests"
    static let optics = "BowOpticsTests"
    static let recursionSchemes = "BowRecursionSchemesTests"
    static let free = "BowFreeTests"
    static let generic = "BowGenericTests"
}

extension Product {
    static var core: Product {
        .library(
            name: Module.core,
            targets: [Module.core])
    }
    
    static var effects: Product {
        .library(
            name: Module.effects,
            targets: [Module.effects])
    }
    
    static var optics: Product {
        .library(
            name: Module.optics,
            targets: [Module.optics])
    }
    
    static var rx: Product {
        .library(
            name: Module.rx,
            targets: [Module.rx])
    }
    
    static var generic: Product {
        .library(
            name: Module.generic,
            targets: [Module.generic])
    }
    
    static var free: Product {
        .library(
            name: Module.free,
            targets: [Module.free])
    }
    
    static var recursionSchemes: Product {
        .library(
            name: Module.recursionSchemes,
            targets: [Module.recursionSchemes])
    }
    
    static var laws: Product {
        .library(
            name: Module.laws,
            targets: [Module.laws])
    }
    
    static var effectsLaws: Product {
        .library(
            name: Module.effectsLaws,
            targets: [Module.effectsLaws])
    }
    
    static var opticsLaws: Product {
        .library(
            name: Module.opticsLaws,
            targets: [Module.opticsLaws])
    }
    
    static var generators: Product {
        .library(
            name: Module.generators,
            targets: [Module.generators])
    }
    
    static var effectsGenerators: Product {
        .library(
            name: Module.effectsGenerators,
            targets: [Module.effectsGenerators])
    }
    
    static var rxGenerators: Product {
        .library(
            name: Module.rxGenerators,
            targets: [Module.rxGenerators])
    }
    
    static var freeGenerators: Product {
        .library(
            name: Module.freeGenerators,
            targets: [Module.freeGenerators])
    }
}

extension Target {
    static var bow: Target {
        .target(name: Module.core)
    }

    static var bowOptics: Target {
        .target(
            name: Module.optics,
            dependencies: [.core])
    }

    static var bowEffects: Target {
        #if os(Linux)
        return .target(
            name: Module.effects,
            dependencies: [.core],
            exclude: ["Foundation/FileManager+iOS+Mac.swift"])
        #else
        return .target(
            name: Module.effects,
            dependencies: [.core])
        #endif
    }

    static var bowRecursionSchemes: Target {
        .target(
            name: Module.recursionSchemes,
            dependencies: [.core])
    }

    static var bowFree: Target {
        .target(
            name: Module.free,
            dependencies: [.core])
    }

    static var bowGeneric: Target {
        .target(
            name: Module.generic,
            dependencies: [.core])
    }

    static var bowRx: Target {
        .target(
            name: Module.rx,
            dependencies: [.core, .effects, .rxSwift, .rxCocoa])
    }

    static var bowLaws: Target {
        .target(
            name: Module.laws,
            dependencies: [.generators],
            path: "Tests/BowLaws")
    }

    static var bowEffectsLaws: Target {
        .target(
            name: Module.effectsLaws,
            dependencies: [.effects, .laws],
            path: "Tests/BowEffectsLaws")
    }

    static var bowOpticsLaws: Target {
        .target(
            name: Module.opticsLaws,
            dependencies: [.optics, .laws],
            path: "Tests/BowOpticsLaws")
    }
    
    static var bowGenerators: Target {
        .target(
            name: Module.generators,
            dependencies: [.core, .swiftCheck],
            path: "Tests/BowGenerators")
    }

    static var bowFreeGenerators: Target {
        .target(
            name: Module.freeGenerators,
            dependencies: [.free, .generators],
            path: "Tests/BowFreeGenerators")
    }

    static var bowEffectsGenerators: Target {
        .target(
            name: Module.effectsGenerators,
            dependencies: [.effects, .generators],
            path: "Tests/BowEffectsGenerators")
    }

    static var bowRxGenerators: Target {
        .target(
            name: Module.rxGenerators,
            dependencies: [.rx, .generators],
            path: "Tests/BowRxGenerators")
    }

    static var bowTests: Target {
        .testTarget(
            name: Test.core,
            dependencies: [.laws])
    }

    static var bowOpticsTests: Target {
        .testTarget(
            name: Test.optics,
            dependencies: [.opticsLaws])
    }

    static var bowRecursionSchemesTests: Target {
        .testTarget(
            name: Test.recursionSchemes,
            dependencies: [.recursionSchemes, .laws])
    }

    static var bowFreeTests: Target {
        .testTarget(
            name: Test.free,
            dependencies: [.freeGenerators, .laws])
    }

    static var bowGenericTests: Target {
        .testTarget(
            name: Test.generic,
            dependencies: [.generic])
    }

    static var bowEffectsTests: Target {
        .testTarget(
            name: Test.effects,
            dependencies: [.effectsGenerators, .effectsLaws])
    }

    static var bowRxTests: Target {
        .testTarget(
            name: Test.rx,
            dependencies: [.rxGenerators, .effectsGenerators, .effectsLaws])
    }
}

extension Target.Dependency {
    static var core: Target.Dependency {
        .target(name: Module.core)
    }
    
    static var effects: Target.Dependency {
        .target(name: Module.effects)
    }
    
    static var optics: Target.Dependency {
        .target(name: Module.optics)
    }
    
    static var rx: Target.Dependency {
        .target(name: Module.rx)
    }
    
    static var free: Target.Dependency {
        .target(name: Module.free)
    }
    
    static var generic: Target.Dependency {
        .target(name: Module.generic)
    }
    
    static var recursionSchemes: Target.Dependency {
        .target(name: Module.recursionSchemes)
    }
    
    static var laws: Target.Dependency {
        .target(name: Module.laws)
    }
    
    static var opticsLaws: Target.Dependency {
        .target(name: Module.opticsLaws)
    }
    
    static var effectsLaws: Target.Dependency {
        .target(name: Module.effectsLaws)
    }
    
    static var generators: Target.Dependency {
        .target(name: Module.generators)
    }
    
    static var effectsGenerators: Target.Dependency {
        .target(name: Module.effectsGenerators)
    }
    
    static var rxGenerators: Target.Dependency {
        .target(name: Module.rxGenerators)
    }
    
    static var freeGenerators: Target.Dependency {
        .target(name: Module.freeGenerators)
    }
    
    static var rxSwift: Target.Dependency {
        .product(name: "RxSwift", package: "RxSwift")
    }
    
    static var rxCocoa: Target.Dependency {
        .product(name: "RxCocoa", package: "RxSwift")
    }
    
    static var swiftCheck: Target.Dependency {
        .product(name: "SwiftCheck", package: "SwiftCheck")
    }
}
