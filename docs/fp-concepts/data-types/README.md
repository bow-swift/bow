---
layout: docs
title: Data types
permalink: /docs/fp-concepts/data-types/
---

# Data types

 {:.beginner}
 beginner

 A data type is an abstraction that encapsulates a reusable coding pattern. Data types are generalized by one or more type parameters. Data types in Bow have Higher Kinded Type support by extending `Kind`.
 
 All data types included in Bow are immutable; that is, you can only set their state during the initialization of the value. Whenever one of the methods need to change the state of the receiving value, a new copy of that value is returned. This way, we can easily reason about the behavior of our code.

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
 | Action&lt;A&gt; | Represents an input on a Moore machine. |
 | ArrayK&lt;A&gt; | Represents an array of values of type `A`. It is like `Array<A>;` or `[A]`, but with HKT support.|
 | Const<A, T> | Represents a constant value of type `A` and a phantom type `T`.|
 | CoSum&lt;F, G, A&gt; | Represents an action to change the selected content in a `Sum` value. |
 | Day&lt;F, G, A&gt; | Represents the Day convolution of functors `F` and `G`. |
 | DictionaryK<K, A> | Represents a dictionary where keys have type `K` and values have type `A`. It is like `Dictionary<K, A>` or `[K: A]`, but with HKT support.|
 | Either<A, B> | Represents the sum type of `A` and `B`; i.e., it holds a value of either one of those types.|
 | Endo&lt;A&gt;| Represents an endomorphism on type `A`; i.e. a function where the input and output have the same type. |
 | Eval&lt;A&gt; | Represents a potentially lazy value of type `A`. |
 | Id&lt;A&gt; | Represents a value of type `A` with no further context.|
 | Ior<A, B> | Represents a value of either `A` or `B`, or both values at the same time.|
 | Moore<E, V> | Represents a Moore machine rendering items of type `V` and handling inputs of type `E`. |
 | NonEmptyArray&lt;A&gt; | Represents an array of one or more elements of type `A`.|
 | Option&lt;A&gt; | Represents a value of type `A` that may or may not be present. It is like `Optional<A>` or `A?`, but with HKT support.|
 | Pairing<F, G> | Represents a relationship between Functors `F` and `G` where they can annihilate each other to yield a value. |
 | Puller&lt;A&gt; | Represents an action to move the focus of a `Zipper`. |
 | SetK&lt;A&gt; | Represents an unordered collection of unique values of type `A`. It is like `Set<A>` but with HKT support. |
 | Sum<F, G, A> | Represents two values in the contexts of `F` and `G`, where only one of them is selected. |
 | Trampoline&lt;A&gt; | Represents a recursive computation that can be converted into a loop. |
 | Try&lt;A&gt; | Represents a computation that may have provided a value of type `A` or thrown an error.|
 | Validated<A, B> | Represents a value that may be invalid, with an error value of type `A`, or a valid value of type `B`.
 | Zipper&lt;A&gt; | Represents an array of values that is focused at a specific position. |

### Transformers

 | Data type | Purpose |
 | --------- | ------- |
 | CoT&lt;W, M, A&gt; | Represents the dual MonadTransformer of the `W` Comonad, with `M` as the base Monad. |
 | Co<W, A> | Represents a CoT where the base Monad is Id. |
 | EitherT<F, A, B> | Represents an `Either<A, B>` nested in an arbitrary effect `F`.|
 | EnvT<E, W, A> | Represents a Comonadic value that is extended with a global environment. |
 | Env<E, A> | Represents an EnvT where the base Comonad is Id. |
 | OptionT<F, A> | Represents an `Option<A>` nested in an arbitrary effect `F`.|
 | StateT<F, S, A> | Represents a function that receives an effect of type `S` and produces a new state of the same type and an output value of type `A`, all wrapped in an effect of type `F`.|
 | State<S, A> | Represents a StateT where the effect is Id.|
 | StoreT<S, W, A> | Represents a Comonadic value that is extended with a focus of type `S`. |
 | Store<S, A> | Represents a StoreT where the base Comonad is Id. |
 | TracedT<M, W, A> | Represents a Comonadic value that is extended to depend in a monoidal position. |
 | Traced<M, A> | Represents a TracedT where the base Comonad is Id. |
 | WriterT<F, W, A> | Represents a value of type `A` under the effect `F` that produces a side stream of data of type `W`.|
