---
layout: docs
title: Bow docs
permalink: /docs/
---

<img src="https://bow-swift.io/img/bow-brand-color.png" height="200" width="200">

[![Build Status](https://travis-ci.org/bow-swift/bow.svg?branch=master)](https://travis-ci.org/bow-swift/bow)
[![codecov](https://codecov.io/gh/bow-swift/bow/branch/master/graph/badge.svg)](https://codecov.io/gh/bow-swift/bow)
[![Gitter](https://badges.gitter.im/bowswift/bow.svg)](https://gitter.im/bowswift/bow?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Bow is a library for Typed Functional Programming in Swift.

## Modules

Bow is split in multiple modules that can be consumed independently. These modules are:

- `Bow`: core library. Contains Higher Kinded Types emulation, function manipulation utilities, Typeclasses, Data Types, Monad Transformers and instances for primitive types.
- `BowOptics`: module to work with different optics.
- `BowRecursionSchemes`: module to work with recursion schemes.
- `BowFree`: module to work with Free Monads.
- `BowGeneric`: module to work with generic data types.
- `BowEffects`: module to work with effects.
- `BowResult`: module to provide an integration with Result.
- `BowBrightFutures`: module to provide an integration with BrightFutures.
- `BowRx`: module to provide an integration with RxSwift.

Bow is available using CocoaPods, Carthage and Swift Package Manager.

### CocoaPods

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

### Carthage

Carthage will download the whole Bow project, but it will compile individual frameworks for each module that you can use separately. Add this line to your Cartfile:

```
github "bow-swift/Bow" ~> 0.3.0
```

### Swift Package Manager

Create a `Package.swift` file similar to the next one and use the dependencies at your convenience.

```
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

## Contributing

If you want to contribute to this library, you can check the [Issues](https://github.com/arrow-kt/bow/issues) to see some of the pending task.

### How to run the project

If you don't have carthage, install it first:

`brew install carthage`

After this, grab all the project dependencies running:

`carthage bootstrap`

Now, you can open `Bow.xcodeproj` with Xcode and run the test to see that everything is working.

# License

    Copyright (C) 2018 The Bow Authors

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
