---
layout: docs
title: Getting started
permalink: /docs/quick-start/getting-started/
---

# Getting started

 Bow is available using CocoaPods, Carthage and Swift Package Manager. You can use any of these tools to add external dependencies to your project.

 You will need to replace `{version}` below by the version of the modules that you would like to use in your project. For a list of available versions, check the [releases page](https://github.com/bow-swift/bow/releases) in the GitHub repository.

## Swift Package Manager

  Starting on Xcode 11, you can use the integration in the IDE with Swift Package manager to bring the dependencies into your project. You only need the repository URL: [https://github.com/bow-swift/bow.git](https://github.com/bow-swift/bow.git). For earlier versions of Xcode, create a `Package.swift` file similar to the next one and use the dependencies at your convenience.

 ```swift
 // swift-tools-version:5.0

 import PackageDescription

 let package = Package(
     name: "BowTestProject",
     dependencies: [
         .package(url: "https://github.com/bow-swift/bow.git", from: "{version}")
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
                     "BowRx"]),
         .testTarget(name: "BowTestProjectTests",
                     dependencies: [
                         // Type class laws
                         "BowLaws",
                         "BowOpticsLaws",
                         "BowEffectsLaws",
  
                         // Generators for PBT with SwiftCheck
                         "BowGenerators",
                         "BowFreeGenerators",
                         "BowEffectsGenerators",
                         "BowRxGenerators"])
     ]
 )
 ```

  Feel free to include or remove the targets above at your convenience. To build the project, just run the following command in the terminal:

  ```
  $ swift build
  ```
 
## CocoaPods

 You can consume each Bow module as a separate pod. You can add these lines to your Podfile at your convenience:

 ```ruby
 pod "Bow",                 "~> {version}"
 pod "BowOptics",           "~> {version}"
 pod "BowRecursionSchemes", "~> {version}"
 pod "BowFree",             "~> {version}"
 pod "BowGeneric",          "~> {version}"
 pod "BowEffects",          "~> {version}"
 pod "BowRx",               "~> {version}"
 ```

 Bow also provides some pods for testing that can be consumed with:

 ```ruby
 pod "BowLaws",        "~> {version}"
 pod "BowOpticsLaws",  "~> {version}"
 pod "BowEffectsLaws", "~> {version}"
 ```

 And generators for property-based testing with SwiftCheck:
 
 ```ruby
 pod "BowGenerators",              "~> {version}"
 pod "BowFreeGenerators",          "~> {version}"
 pod "BowEffectsGenerators",       "~> {version}"
 pod "BowRxGenerators",            "~> {version}"
 ```

 After including the pods you would like to use in your Podfile, run the following command in the terminal:

```
$ pod install
```

It will generate an Xcode workspace. If you open it, you will have your project configured to import the modules that you included in your Podfile.

For further instructions on how to get CocoaPods installed and troubleshooting, visit [their website](https://cocoapods.org/).

## Carthage

 Carthage will download the whole Bow project, but it will compile individual frameworks for each module that you can use separately. Add this line to your Cartfile:

 ```
 github "bow-swift/Bow" ~> {version}
 ```

 Then, run the following command in the terminal:

```
$ carthage bootstrap
```

 For further instructions on how to get Carthage installed and troubleshooting, and how to link the compiled frameworks into your project, visit their [GitHub repository](https://github.com/Carthage/Carthage).
