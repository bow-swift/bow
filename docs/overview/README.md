---
layout: docs
title: Overview
permalink: /docs/effects/overview/
---

# Effects
 
 {:.beginner}
 beginner
 
 The `BowEffects` module provides a foundation to work with side effects in a functional manner. In order to use it, you only need to import it:

```swift
import BowEffects
```

 This module includes multiple facilities to work with side effects:
 
 - **Type classes**: abstractions to suspend side effects and execute them asynchronous and concurrently.
 - **IO**: a powerful data type to encapsulate side effects and work with them in a functional manner.
 - **Utilities**: data types to work with resources and shared state functionally.
 
## Type classes
 
 Type classes in the Effects module abstract over the suspension of effects and their asynchronous and concurrent execution. The module contains the following type classes:
 
 | Type class       | Description                                             |
 | ---------------- | ------------------------------------------------------- |
 | MonadDefer       | Enables delaying the evaluation of a computation        |
 | Async            | Enables running asynchronous computations that may fail |
 | Bracket          | Provides safe resource acquisition, usage and release   |
 | Effect           | Enables suspension of side effects                      |
 | Concurrent       | Enables concurrent execution of asynchronous operations |
 | ConcurrentEffect | Enables cancelation of effects running concurrently     |
 | UnsafeRun        | Enables unsafe execution of side effects                |
 
## IO
 
 The IO data type is the core data type to provide suspension of side-effects. Its API lets us do powerful transformations and composition, and eventually evaluate them concurrently and asynchronously.
 
 IO also provides error handling capabilities. It lets us specify explicitly the type of errors that may happen in its underlying encapsulated side-effects and the type of values it produces.
 
 There are several variants of IO depending on the needs of our program:
 
 | Variant        | Description |
 | -------------- | ----------- |
 | IO&lt;E, A&gt; | An encapsulated side effect producing values of type `A` and errors of type `E` |
 | UIO&lt;A&gt;   | An encapsulated side effect producing values of type `A` that will never fail |
 | Task&lt;A&gt;  | An encapsulated side effect producing values of type `A` and no explicit error type (using `Error`) |
 
 Besides, if we want to model side effects depending on a context of type `D`, we can use the `EnvIO<D, E, A>` type, or any of its variants:
 
 | Variant              | Description |
 | -------------------- | ----------- |
 | EnvIO&lt;D, E, A&gt; | A side effect depending on context `D` that produces values of type `A` and errors of type `E` |
 | URIO&lt;D, A&gt;     | A side effect depending on context `D` that produces values of type `A` and will never fail |
 | RIO&lt;D, A&gt;       | A side effect depending on context `D` that produces values of type `A` and no explicit error type (using `Error`) |
 
## Utilities
 
 Besides the IO data types, the Effects module provides some utilities:
 
 | Data type | Description |
 | --------- | ----------- |
 | Atomic&lt;A&gt; | An atomically modifiable reference to a value |
 | Ref&lt;F, A&gt; | An asynchronous, concurrent mutable reference providing safe functional access and modification of its content |
 | Resource&lt;F, A&gt; | A resource that provides safe allocation, usage and release |
 
