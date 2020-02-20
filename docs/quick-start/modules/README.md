---
layout: docs
title: Modules
permalink: /docs/quick-start/modules/
---

# Modules

 Bow is split in multiple modules that can be imported independently. These modules are:

 {:.beginner}
 beginner

 | Module | Description | Swift import |
 | ------ | ----------- | ------------ |
 | Core | Higher Kinded Types emulation, function manipulation utilities, type classes, data types, monad transformers and instances for primitive types. | `import Bow` |
 | Effects | Encapsulation of side effects. | `import BowEffects` |

 {:.intermediate}
 intermediate

 | Module | Description | Swift import |
 | ------ | ----------- | ------------ |
 | Optics | Immutable data structures manipulation. | `import BowOptics` |
 | BrightFutures | Integration with the BrightFutures library. | `import BowBrightFutures` |
 | RxSwift | Integration with the RxSwift library. | `import BowRx` |

 {:.advanced}
 advanced

 | Module | Description | Swift import |
 | ------ | ----------- | ------------ |
 | Recursion Schemes | Recursive data structures, F-algebras and folding / unfolding functions. | `import BowRecursionSchemes` |
 | Free | Free monads. | `import BowFree` |
 | Generic | Data types for generic programming. | `import BowGeneric` |
 
# Modules for testing
 
 Bow also provides some modules that are used in testing. These modules are:
 
## Generators for Property-based Testing with SwiftCheck
 
 {:.intermediate}
 intermediate
 
 | Module | Description | Swift import |
 | ------ | ----------- | ------------ |
 | Generators | Generators for data types in the core module | `import BowGenerators` |
 | FreeGenerators | Generators for data types in BowFree | `import BowFreeGenerators` |
 | EffectsGenerators | Generators for data types in BowEffects | `import BowEffectsGenerators` |
 | RxGenerators | Generators for data types in BowRx | `import BowRxGenerators` |
 | BrightFuturesGenerators | Generators for data types in BowBrightFutures | `import BowBrightFuturesGenerators` |
 
## Laws to test instances of type classes
 
 {:.intermediate}
 intermediate
 
 | Module | Description | Swift import |
 | ------ | ----------- | ------------ |
 | Laws | Laws for type classes in the core module | `import BowLaws` |
 | OpticsLaws | Laws for optics | `import BowOpticsLaws` |
 | EffectsLaws | Laws for effects | `import BowEffectsLaws` |
 
