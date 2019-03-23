// nef:begin:header
/*
 layout: docs
 title: Getting started
 */
// nef:end
/*:
 # Getting started
 
 Bow is available using CocoaPods, Carthage and Swift Package Manager.
 
 ## CocoaPods
 
 You can consume each Bow module as a separate pod. You can add these lines to your Podfile at your convenience:
 
 ```ruby
 pod "Bow",                 "~> 0.3.0"
 pod "BowOptics",           "~> 0.3.0"
 pod "BowRecursionSchemes", "~> 0.3.0"
 pod "BowFree",             "~> 0.3.0"
 pod "BowGeneric",          "~> 0.3.0"
 pod "BowResult",           "~> 0.3.0"
 pod "BowEffects",          "~> 0.3.0"
 pod "BowRx",               "~> 0.3.0"
 pod "BowBrightFutures",    "~> 0.3.0"
 ```
 
 ## Carthage
 
 Carthage will download the whole Bow project, but it will compile individual frameworks for each module that you can use separately. Add this line to your Cartfile:
 
 ```
 github "bow-swift/Bow" ~> 0.3.0
 ```
 
 ## Swift Package Manager
 
 Create a `Package.swift` file similar to the next one and use the dependencies at your convenience.

    ```swift
    // swift-tools-version:4.0

    import PackageDescription

    let package = Package(
        name: "BowTestProject",
        dependencies: [
            .package(url: "https://github.com/bow-swift/bow.git", from: "0.3.0")
        ],
        targets: [
            .target(name: "BowTestProject",
                    dependencies: [
                        "Bow",
                        "BowOptics",
                        "BowRecursionSchemes",
                        "BowFree",
                        "BowGeneric",
                        "BowEffects",
                        "BowResult",
                        "BowRx",
                        "BowBrightFutures"]
            )
        ]
    )
    ```
 
 To build it, just run:
 
 ```
 $ swift build
 ```
 */
