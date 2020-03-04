---
layout: docs
title: Type classes
permalink: /docs/fp-concepts/type-classes/
---

# Type classes

 {:.intermediate}
 intermediate
 
 **Type classes**, also known as extension interfaces, are usually represented in Swift as protocols with associated types and/or `Self` requirements. They are groups of functions that operate on generic type parameters and are governed by algebraic laws.

 Type classes can be used to enable **ad hoc polymorphism**; they act as constraints added to type parameters in parametrically polymorphic types or functions.

 Consider, for instance, the `Equatable` protocol. It is a type class that adds some functionality to existing types; more precisely, it enables to check for equality of values of a type. It is governed by the following laws:

 - Identity: a value is equal to itself (`a == a`).
 - Symmetry: if `a == b`, then `b == a`.
 - Transitivity: if `a == b` and `b == c`, then `a == c`.

 The `Equatable` type class can be used to constrain implementations of parametrically polymorphic functions; e.g:

```swift
func allEqual<A: Equatable>(_ array: [A]) -> Bool {
    guard let first = array.first else { return false }
    return array.reduce(true) { partial, next in partial && next == first }
}
```

 The function above is parametrically polymorphic; it operates of values of type `A`. Valid types to fill this type parameter need to conform to `Equatable` and enable the possibility to use the `==` operator.

## Type classes of higher kind

 `Equatable`, like many other protocols provided by Foundation or any other Swift framework, operates at the type level. However, there are many other interesting abstractions as type classes that need to operate at higher kind level. This is not possible by default in Swift, but Bow simulates HKTs and enables type classes to work at this level.

 Let us consider the following example. We can try to define a type class that enables transforming values in containers; i.e., given an `F<A>`, we would like to obtain an `F<B>`, provided that we know how to transform from `A` to `B`:

 - `F<A>` is not possible to be written natively in Swift. Bow supports this feature by writing it as `Kind<F, A>`.
 - Transforming from `A` to `B` corresponds to a function `(A) -> B`.
 - Since this type class is intended to work on kinds `* -> *`, it should be implemented by `F`, so in the context of the definition of the type class, we can refer to `F` as a `Self` requirement.

 Therefore, the definition of the type class may be:

```swift
protocol Transformer {
    static func transform<A, B>(_ fa: Kind<Self, A>, _ f: (A) -> B) -> Kind<Self, B>
}
```

## Type class laws

 As we mentioned above, type classes are governed by **algebraic laws**. This means that all implementations of the type class must behave on a certain and satisfy some properties. Each type class has its own laws, as the ones we presented for `Equatable` above.

 For the `Transformer` type class that we are defining, we can consider some laws as well:

 - **Identity**: if we transform using the identity function (`id`), we must obtain the original value; i.e., `F.transform(fa, id) == fa`.
 - **Composition**: if we apply two transformations to a value, we must obtain the same result as if we apply a single transformation with the composition of the two transforming functions; i.e., `F.transform(F.transform(fa, f), g) == F.transform(fa, g <<< f)`.

 Swift does not provide a way of encoding these laws and enforcing them in every implementation. To do this, Bow type classes encode their laws as property-based tests using [SwiftCheck](https://github.com/typelift/SwiftCheck). Then, each implementation can be tested against these laws to guarantee that the implementation satisfies them. Type class laws help us have a better reasoning about our code and some times help us rewrite pieces for optimization (like in the case of `Transformer` where we can compose functions and apply a single transformation instead of two).

 Notice that sometimes you can provide an implementation for a given type class that does not satisfy the laws. Those are called **lawless instances**, in contrast to the ones that satisfy them, which are called **lawful instances**.

## Type class instances

 A **type class instance** is a concrete implementation of a type class for a given type. Instances are usually created through the extension mechanisms that Swift provides. For instance, let us provide an instance of `Transformer` for the `Option` data type in Bow:

```swift
extension ForOption: Transformer {
    static func transform<A, B>(_ fa: Kind<ForOption, A>, _ f: (A) -> B) -> Kind<ForOption, B> {
        return fa^.fold(Option<B>.none,                // It is empty, no transformation
                        { a in Option<B>.some(f(a)) }) // Transformed with f and wrapped in an Option<B>
    }
}
```

 Notice that, since the type class works at the kind level, it is not an extension of `Option`, but an extension of `ForOption`. Revisiting the definition of `Transformer`, the `Self` requirement is used in `Kind<Self, A>`. If we dissect the definition of `Option<A>`, it extends `Kind<ForOption, A>`. By doing some sort of pattern matching between `Kind<Self, A>` and `Kind<ForOption, A>`, we can see that it must be `ForOption` the candidate to do the extension.

 In the case of types with a higher kind, like `Either`, we can resort to the same strategy: `Either<L, R>` is equivalent to Kind<EitherPartial<L>, R>`, so the extension should be made on `EitherPartial<L>`. Take a look at the following table for examples on some of the types in the core module for Bow.

 | Type          | What to extend for a type class like Transformer? |
 | ------------- | ------------------------------------------------- |
 | ArrayK        | extension ForArrayK: Transformer { ... }          |
 | Const         | extension ConstPartial: Transformer { ... }       |
 | Either        | extension EitherPartial: Transformer { ... }      |
 | Id            | extension ForId: Transformer { ... }              |
 | Ior           | extension IorPartial: Transformer { ... }         |
 | NonEmptyArray | extension ForNonEmptyArray : Transformer { ... }  |
 | Option        | extension ForOption: Transformer { ... }          |
 | Try           | extension ForTry: Transformer { ... }             |
 | Validated     | extension ValidatedPartial: Transformer { ... }   |

## Projecting syntax on `Kind`

 Type classes that operate on kinds can project some methods on this type so that they are easier to use. This is achieved through extension too; we can extend `Kind` with a constraint on its `F` type, and enable the syntax for transformer as an instance method:

```swift
extension Kind where F: Transformer {
    func transform<B>(_ f: (A) -> B) -> Kind<F, B> {
        return F.transform(self, f)
    }
}
```

 This way, every type that its witness has an instance of `Transformer`, will be able to use `transform` as an instance method. We have two ways of using this type class; consider a function to multiply by two the values contained in some structure:

```swift
func multiplyByTwo_firstVersion<F: Transformer>(_ value: Kind<F, Int>) -> Kind<F, Int> {
    return F.transform(value, { x in 2 * x })
}

func multiplyByTwo_secondVersion<F: Transformer>(_ value: Kind<F, Int>) -> Kind<F, Int> {
    return value.transform { x in 2 * x }
}
```

 Both versions are equivalent. Type classes defined in Bow project their methods as instance or static methods in Kind to make them easier to find and use. Notice that the compiler is able to resolve which instance it needs to provide based on the type that we use to call the function:

```swift
let some = multiplyByTwo_firstVersion(Option.some(1))
let none = multiplyByTwo_secondVersion(Option.none())
```

## Existing type classes in Bow

 The reader may have guessed that the `Transformer` type class that we have created above is, in fact, the `Functor` type class, and `transform` corresponds to `map`. Bow modules include multiple type classes, like `Functor`, with their corresponding instances. The following tables summarize some of them; for further information, refer to the API reference for each one of them.

 | Type class | Purpose |
 | ---------- | ------- |
 | Semigroup | Combine two objects of the same type |
 | Monoid | Combinable objects have an empty value |
 | SemigroupK | Combine two kinds of the same type |
 | MonoidK | Combinable kinds have an empty value |
 | Functor | Transform the contents of an effect, preserving its structure |
 | Applicative | Perform independent computations |
 | Monad | Perform sequential computations |
 | ApplicativeError | Recover from errors in independent computations |
 | MonadError | Recover from errors in sequential computations |
 | Comonad | Extract values from a structure |
 | Bimonad | Monad and Comonad behavior |
 | Foldable | Summarize values of a structure into a single value |
 | Traverse | Apply effects on the values of a structure |
 | FunctorFilter | Transform values based on a predicate |
 | MonadFilter | Execute values that pass a predicate, sequentially |
 | TraverseFilter | Traverse values that pass a predicate |
 | MonadReader | A Monad with capabilities to read from a shared environment |
 | MonadWriter | A Monad with the ability to produce a stream of data in addition to the computed values |
 | MonadState | A Monad with the ability to maintain (read and write) a state |
