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

## Documentation

All documentation and API reference is published in [our website](https://bow-swift.io/). Some links to key aspects of the library:

- [Higher Kinded Type emulation](https://bow-swift.io/next/docs/fp-concepts/higher-kinded-types/)
- [Type classes](https://bow-swift.io/next/docs/fp-concepts/type-classes/)
- [Data types](https://bow-swift.io/next/docs/fp-concepts/data-types/)
- [Optics](https://bow-swift.io/next/docs/optics/overview/)
- [Effects](https://bow-swift.io/next/docs/effects/overview/)
- [Streams](https://bow-swift.io/next/docs/integrations/rxswift-streams/)

## Modules

Bow is split into multiple modules that can be consumed independently. These modules are:

- `Bow`: core library. Contains Higher Kinded Types emulation, function manipulation utilities, Typeclasses, Data Types, Monad Transformers, and instances for primitive types.
- `BowOptics`: module to work with different optics.
- `BowRecursionSchemes`: module to work with recursion schemes.
- `BowFree`: module to work with Free Monads.
- `BowGeneric`: module to work with generic data types.
- `BowEffects`: module to work with effects.
- `BowRx`: module to provide an integration with RxSwift.

There are also some modules for testing:

- `BowLaws`: laws for type classes in the core module.
- `BowOpticsLaws`: laws for optics.
- `BowEffectsLaws`: laws for effects.
- `BowGenerators`: generators for Property-based Testing for data types in the core module.
- `BowFreeGenerators`: generators for Property-based Testing for data types in BowFree.
- `BowEffectsGenerators`: generators for Property-based Testing for data types in BowEffects.
- `BowRxGenerators`: generators for Property-based Testing for data types in BowRx.

Bow is available using Swift Package Manager, CocoaPods, and Carthage.

### Swift Package Manager

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

To build it, just run:

```
$ swift build
```

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
```

### Carthage

Carthage will download the whole Bow project, but it will compile individual frameworks for each module that you can use separately. Add this line to your Cartfile:

```
github "bow-swift/Bow" ~> {version}
```

## Contributing

If you want to contribute to this library, you can check the [Issues](https://github.com/arrow-kt/bow/issues) to see some of the pending tasks.

### How to run the project

Open `Bow.xcodeproj` in Xcode 11 (or newer) and you are ready to go. Bow uses the Swift Package Manager to handle its dependencies.

### How to run the documentation project

- Go to the directory `contents/Documentation`.
- Run `pod install` to get all dependencies.
- Open `Documentation.xcworkspace` and run the project.

For further information, refer to our [Contribution guidelines](CONTRIBUTING.md).

## How to create a new release

You can create a new release by running `bundle exec fastlane release version_number:`. For example, `bundle exec fastlane release version_number: 0.6.0`.

The following steps would be run:

- Update the `version` in `*.podspec` files.
- Create a tag with message added in the `CHANGELOG` file.
- Deploy podspec files and make them publicly available.

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
