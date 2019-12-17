---
layout: docs
title: Getting started
permalink: /docs/quick-start/getting-started/
---

# Getting started

 Bow is available using CocoaPods, Carthage and Swift Package Manager. You can use any of these tools to add external dependencies to your project.

 You will need to replace `{version}` below by the version of the modules that you would like to use in your project. For a list of available versions, check the [releases page](https://github.com/bow-swift/bow/releases) in the GitHub repository.

## CocoaPods

 You can consume each Bow module as a separate pod. You can add these lines to your Podfile at your convenience:

 ```ruby
 pod "Bow",                 "~> {version}"
 pod "BowOptics",           "~> {version}"
 pod "BowRecursionSchemes", "~> {version}"
 pod "BowFree",             "~> {version}"
 pod "BowGeneric",          "~> {version}"
 pod "BowResult",           "~> {version}"
 pod "BowEffects",          "~> {version}"
 pod "BowRx",               "~> {version}"
 pod "BowBrightFutures",    "~> {version}"
 ```

After that, run the following command in the terminal:

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

## Swift Package Manager

 Create a `Package.swift` file similar to the next one and use the dependencies at your convenience.

```swift
// swift-tools-version:4.0

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
                    "BowResult",
                    "BowRx",
                    "BowBrightFutures"]
        )
    ]
)
```

 To build it, just run the following command in the terminal:

 ```
 $ swift build
 ```
