![](https://github.com/bow-swift/bow-art/blob/master/assets/bow-header-github.png?raw=true)

<p align="center">
<a href="https://travis-ci.org/bow-swift/bow">
<img src="https://travis-ci.org/bow-swift/bow.svg?branch=master">
</a>
<a href="https://codecov.io/gh/bow-swift/bow">
<img src="https://codecov.io/gh/bow-swift/bow/branch/master/graph/badge.svg">
</a>
<a href="https://gitter.im/bowswift/bow?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge">
<img src="https://badges.gitter.im/bowswift/bow.svg">
</a>
</p>

Bow is a library for Typed Functional Programming in Swift.

## Modules

Bow is split into multiple modules that can be consumed independently. These modules are:

- `Bow`: core library. Contains Higher Kinded Types emulation, function manipulation utilities, Typeclasses, Data Types, Monad Transformers, and instances for primitive types.
- `BowOptics`: module to work with different optics.
- `BowRecursionSchemes`: module to work with recursion schemes.
- `BowFree`: module to work with Free Monads.
- `BowGeneric`: module to work with generic data types.
- `BowEffects`: module to work with effects.
- `BowBrightFutures`: module to provide an integration with BrightFutures.
- `BowRx`: module to provide an integration with RxSwift.

There are also some modules for testing:

- `BowLaws`: laws for type classes in the core module.
- `BowOpticsLaws`: laws for optics.
- `BowEffectsLaws`: laws for effects.
- `BowGenerators`: generators for Property-based Testing for data types in the core module.
- `BowFreeGenerators`: generators for Property-based Testing for data types in BowFree.
- `BowEffectsGenerators`: generators for Property-based Testing for data types in BowEffects.
- `BowRxGenerators`: generators for Property-based Testing for data types in BowRx.
- `BowBrightFuturesGenerators`: generators for Property-based Testing for data types in BowBrightFutures.

Bow is available using CocoaPods, Carthage, and Swift Package Manager.

### CocoaPods

You can consume each Bow module as a separate pod. You can add these lines to your Podfile at your convenience:

```ruby
pod "Bow",                 "~> {version}"
pod "BowOptics",           "~> {version}"
pod "BowRecursionSchemes", "~> {version}"
pod "BowFree",             "~> {version}"
pod "BowGeneric",          "~> {version}"
pod "BowEffects",          "~> {version}"
pod "BowRx",               "~> {version}"
pod "BowBrightFutures",    "~> {version}"
```

Testing laws:

```ruby
pod "BowLaws",        "~> {version}"
pod "BowOpticsLaws",  "~> {version}"
pod "BowEffectsLaws", "~> {version}"
```

Generators for property-based testing with SwiftCheck:

```ruby
pod "BowGenerators",              "~> {version}"
pod "BowFreeGenerators",          "~> {version}"
pod "BowEffectsGenerators",       "~> {version}"
pod "BowRxGenerators",            "~> {version}"
pod "BowBrightFuturesGenerators", "~> {version}"
```

### Carthage

Carthage will download the whole Bow project, but it will compile individual frameworks for each module that you can use separately. Add this line to your Cartfile:

```
github "bow-swift/Bow" ~> {version}
```

### Swift Package Manager

Create a `Package.swift` file similar to the next one and use the dependencies at your convenience.

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
                    "BowRx",
                    "BowBrightFutures"]),
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
                        "BowRxGenerators",
                        "BowBrightFuturesGenerators"])
    ]
)
```

To build it, just run:

```
$ swift build
```

## Contributing

If you want to contribute to this library, you can check the [Issues](https://github.com/arrow-kt/bow/issues) to see some of the pending tasks.

### How to run the project

If you don't have Carthage, install it first:

`brew install carthage`

After this, grab all the project dependencies running:

`carthage bootstrap`

Now, you can open `Bow.xcodeproj` with Xcode and run the test to see that everything is working.

# License

    Copyright (C) 2018-2019 The Bow Authors

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
