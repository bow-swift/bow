---
layout: docs
title: Data types
permalink: /docs/fp-concepts/data-types/
---

# Data types

 {:.beginner}
 beginner

 A data type is an abstraction that encapsulates a reusable coding pattern. Data types are generalized by one or more type parameters. Data types in Bow have Higher Kinded Type support by extending `Kind`. Their functionality works on their own structure, never on the values defined by its generic type parameters.

## Data types in Bow

 The following tables summarize some of the data types included in Bow, together with a short description of their purpose.

### Function-like types

 | Data type | Purpose |
 | --------- | ------- |
 | Function0&lt;A&gt; | Represents a constant function; one that does not receive any parameters and produces a constant value of type `A`.|
 | Function1<I, O> | Represents a function that receives values of type `I` and produces values of type `O`.|
 | Kleisli<F, D, A> | Represents a function that receives values of type `D` and produces values of type `A` wrapped in an effect `F` (namely, `Kind<F, A>`). Dual of Cokleisli.|
 | ReaderT<F, D, A> | Equivalent to `Kleisli<F, D, A>`.|
 | Reader<D, A> | Represents a ReaderT where the effect is Id.|
 | Cokleisli<F, D, A> | Represents a function that receives values of type `A` wrapped in an effect `F` (namely, `Kind<F, A>`), and produces values of type `D`. Dual of Kleisli.|
 | CoreaderT<F, D, A> | Equivalent to `Cokleisli<F, D, A>`.|
 | Coreader<F, D, A> | Represents a CoreaderT where the effect is Id.|

### Core types

 | Data type | Purpose |
 | --------- | ------- |
 | ArrayK&lt;A&gt; | Represents an array of values of type `A`. It is like `Array&lt;A&gt;` or `[A]`, but with HKT support.|
 | Const<A, T> | Represents a constant value of type `A` and a phantom type `T`.|
 | DictionaryK<K, A> | Represents a dictionary where keys have type `K` and values have type `A`. It is like `Dictionary<K, A>` or `[K: A]`, but with HKT support.|
 | Either<A, B> | Represents the sum type of `A` and `B`; i.e., it holds a value of either one of those types.|
 | Eval&lt;A&gt; | Represents a potentially lazy value of type `A`. |
 | Id&lt;A&gt; | Represents a value of type `A` with no further context.|
 | Ior<A, B> | Represents a value of either `A` or `B`, or both values at the same time.|
 | NonEmptyArray&lt;A&gt; | Represents an array of one or more elements of type `A`.|
 | Option&lt;A&gt; | Represents a value of type `A` that may or may not be present. It is like `Optional&lt;A&gt;` or `A?`, but with HKT support.|
 | SetK&lt;A&gt; | Represents an unordered collection of unique values of type `A`. It is like `Set&lt;A&gt;` but with HKT support. |
 | Try&lt;A&gt; | Represents a computation that may have provided a value of type `A` or thrown an error.|
 | Validated<A, B> | Represents a value that may be invalid, with an error value of type `A`, or a valid value of type `B`.

### Transformers

 | Data type | Purpose |
 | --------- | ------- |
 | EitherT<F, A, B> | Represents an `Either<A, B>` nested in an arbitrary effect `F`.|
 | OptionT<F, A> | Represents an `Option&lt;A&gt;` nested in an arbitrary effect `F`.|
 | StateT<F, S, A> | Represents a function that receives an effect of type `S` and produces a new state of the same type and an output value of type `A`, all wrapped in an effect of type `F`.|
 | State<S, A> | Represents a StateT where the effect is Id.|
 | WriterT<F, W, A> | Represents a value of type `A` under the effect `F` that produces a side stream of data of type `W`.|
