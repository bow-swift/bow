---
layout: docs
title: Home
permalink: /docs/
---

# Bow

Bow is a Functional Programming companion library for Swift. It provides the following utilities:

{:.beginner}
beginner

- **Higher Kinded Types emulation**: Swift does not have native support for Higher Kinded Types, although the Generics Manifesto states it will in the future. However, we added support to begin with as it’s needed in the rest of the library. The emulation is simple, but adds a small amount of boilerplate that we are working to automate.
- **Function manipulation utilities**: operators for composing, currying, reversing, complementing, and memoizing functions are available as part of the core module.
- **Data types**: the core module provides some useful data types like `Option`, `Either`, `Try` and `NonEmptyArray`, as well as wrappers over types in Foundation, like `ListK` and `SetK` that enable using them as Higher Kinded Types.
- **Type classes and instances**: definitions of usual type classes, like `Functor`, `Monad` and `Semigroup` are part of this module. Also, instances for primitive types and the provided data types are available.

{:.intermediate}
intermediate

- **Monad transformers**: work with nested effects in an easy and seamless way with types like `StateT` or `WriterT`.
- **Effects**: encapsulate side effects in the `IO` data type and manipulate it with the corresponding type classes.
- **Optics**: utilities to work with immutable data structures such as `Lenses` and `Prisms`.
- **Integrations**: Bow is compatible with `Result`, `RxSwift` and `BrightFutures`.

{:.advanced}
advanced

- **Recursion schemes**: manipulate recursive data structures with F-algebras and generic folding and unfolding functions.
- **Free monads**: describe your programs using the `Free` monad and create interpreters to concrete implementations.
