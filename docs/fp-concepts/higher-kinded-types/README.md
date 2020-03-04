---
layout: docs
title: Higher Kinded Types
permalink: /docs/fp-concepts/higher-kinded-types/
---

# Higher Kinded Types

 {:.beginner}
 beginner

 Swift does not support Higher Kinded Types (HKTs) yet, although the [Generics Manifesto](https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md#higher-kinded-types) states there are plans to support them natively. However, HKTs are essential to enable Functional Programming with type classes and polymorphism. For this reason, Bow provides lightweight emulation support of HKTs. This document describes how this feature is implemented in Bow and how you can use it to create your own types with HKT support.

## Motivation

 Swift provides support for generic programming, so that we do not have to rewrite the same logic for multiple types. For instance, consider the following two functions:

```swift
func allIntsEqual(_ array: [Int]) -> Bool {
    guard let first = array.first else { return false }
    return array.reduce(true) { partial, next in partial && next == first }
}

func allStringsEqual(_ array: [String]) -> Bool {
    guard let first = array.first else { return false }
    return array.reduce(true) { partial, next in partial && next == first }
}
```

 Both functions have exactly the same code but operate in different types. In order to remove this duplication, we can rewrite the type signature and the implementation could remain the same:

```swift
func allEqual<A: Equatable>(_ array: [A]) -> Bool {
    guard let first = array.first else { return false }
    return array.reduce(true) { partial, next in partial && next == first }
}
```

 Both functions, `allIntsEqual` and `allStringsEqual` can be replaced by `allEqual`, which works for every type `A`, as long as this type conforms to `Equatable`. `A` is known as the **type parameter** and `allEqual` is a function that uses **parametric polymorphism**; i.e. it has *many forms* that depend on the type parameter we use.

 This enables a degree of generic programming where we can create families of functions that work on many types as long as they conform to certain protocols. However, this is not expressive enough. Let us consider the following functions:

```swift
enum DivideError: Error {
    case divisionByZero
}

func divideEither(x: Int, y: Int) -> Either<DivideError, Int> {
    guard y != 0 else { return .left(.divisionByZero) }
    return .right(x / y)
}

func divideValidated(x: Int, y: Int) -> Validated<DivideError, Int> {
    guard y != 0 else { return .invalid(.divisionByZero) }
    return .valid(x / y)
}
```

 We can see some similarities between these two functions. They are checking that the second argument is not 0 to perform the division and wrap it in a right/valid case. Otherwise, the division cannot be performed and they wrap an error in a left/invalid case. It would be helpful to unify these two functions in a similar way as in the `allEqual` example presented above. Hypothetically, we would like to write something like:

 ```swift
 func divide<F: ErrorSuccessRepresentable>(x: Int, y: Int) -> F<DivideError, Int> {
    guard y != 0 else { return .failure(.divisionByZero)
    return .success(x / y)
 }
 ```

 That is, given a type `F` that is able to create success and error values (via the hypothetical `ErrorSuccessRepresentable` protocol), we could write a function that checks if the division can be performed or not, and create the result values accordingly. This would allow us to write generic programs where we can generalize the container types, not only the contained ones.

 Unfortunately, Swift does not support writing the code above since it does not have HKTs support. Can we find a workaround to have this feature?

## Types and Kinds

 Before we answer this question, let us review some basic concepts. The notion of **type** is well-known among software engineers and Swift developers. Being a class, struct or enum, a type is a set of values. This set may be finite, as in the case of `Bool` where there are only two values (`true` and `false`), or infinite, as in the case of `String`. Types group values that are similar. If we raise the level of abstraction, we could group similar types in sets of types; those *sets of types* are **kinds**.

 So, how are types grouped into kinds then? Using notation that comes from Haskell, we can group them like:

 - `*`: read *type*, is the kind of types that do not have type parameters. Examples of types of this kind are `Int`, `String` or `Bool`, but not limited to primitive types; developer created types like `User` or `UIViewController` are also types of this kind.
 - `* -> *`: is the kind of types that receive one type parameter. That includes types which, given a type, can provide another one. Examples of this are `Array<Element>` or `Optional<Wrapped>`; these types, when provided an `Element` or `Wrapped` type, will create a new type in the system.
 - `* -> * -> *`: is the kind of types that receive two type parameters. Similar to the case above, examples of this kind are `Result<Value, Error>` or `Function1<Input, Output>`; when we provide two types to fill their two *holes*, we get a new type back.

 We could go on and on. The important thing to notice here is that, whenever we provide a type parameter, the kind of the resulting type changes.

 For example, we have mentioned that `Array<Element>` is of kind `* -> *`. If we provide a type, like `Int` or `String`, the new type becomes `Array<Int>` or `Array<String>`, which are of kind `*`. Similarly, `Result<Value, Error>` is of kind `* -> * -> *`, `Result<Int, Error>` is of kind `* -> *` (still has one type parameter that has not been fixed), and `Result<Int, DivideError>` is of kind `*`. This means that type constructors can be **partially applied** to obtain new type constructors.

## Emulating HKTs in Bow

 Once we know the limitations of Swift to deal with HKTs and how types are grouped into kinds, we can explore how HKTs can be simulated within the current Swift type system. We mentioned above that we can abstract over the type parameters of a type constructor, but not over the type constructor itself.

 Using this information, we created an intermediate structure where instead of working with `F<A>`, we work with `Kind<F, A>`. `Kind<F, A>` represents types of kind `* -> *`. We have kinds of higher arities; for instance, `F<A, B>` corresponds to `Kind2<F, A, B>`, and represents types of kind `* -> * -> *`. We can continue up to 10 type arguments.

 This is not enough. If you look at the API reference, `Kind` is a class and we would need to extend it in order to have HKT support for our type. Let us assume we would like to implement a `Maybe<A>` type, behaving like a Swift optional value, with HKT support. We have mentioned above that `F<A>` becomes `Kind<F, A>`; therefore, `Maybe<A>` needs to extend `Kind<Maybe, A>`, but this does not compile and has a cycle in the inheritance relationship.

 In order to avoid this, an intermediate class is created. This class is called the **witness** and, as a convention in Bow, they are named as the type they support, with the prefix `For`. Therefore, our type would be `Maybe<A>: Kind<ForMaybe, A>`.

 What about HKTs with higher arity? As we mentioned above, when we partially a type parameter, the kind arity gets reduced in one. We use this to have the following equivalences:

 - `Kind2<F, A, B>` is equivalent to `Kind<Kind<F, A>, B>`.
 - `Kind3<F, A, B, C>` is equivalent to `Kind<Kind2<F, A, B>, C>`.
 - `Kind4<F, A, B, C, D>` is equivalent to `Kind<Kind3<F, A, B, C>, D>`.

 And you can continue the series up to `Kind10`. This means we can partially apply the types and leave the last type parameter, reducing the arity of the kind by one. This is particularly useful when we are working with type classes that operate on kinds.

 So, consider we want to implement an *exclusive or* type that has a value of either one of two types. As we mentioned above, we need a witness class for it:

```swift
final class ForXor {}
```

 For types that have more than one type parameter, it is convenient to write an intermediate type with a partial application:

```swift
final class XorPartial<Left>: Kind<ForXor, Left> {}
```

 And finally, for the sake of readability, we usually create a type alias, named as the type with the suffix `Of`:

```swift
typealias XorOf<Left, Right> = Kind<XorPartial<Left>, Right>
```

 Our exclusive or type can be defined now as:

```swift
class Xor<Left, Right>: XorOf<Left, Right> {}
```

 These 4 lines will give our type the capability of being used as a HKT. It involves writing some boilerplate code that we are working to automate. Bow data types already support this, so you do not need to worry about it; in case you need to write your own types with HKT support, you can follow the process above.

 The following table summarizes the HKT support for some data types in the core module:

 | Data type        | Witness          | Partial application | Type alias         |
 | ---------------- | ---------------- | ------------------- | ------------------ |
 | Function0&lt;A&gt;     | ForFunction0     |                     | Function0Of&lt;A&gt;     |
 | Function1<I, O>  | ForFunction1     | Function1Partial<I> | Function1Of<I, O>  |
 | ArrayK&lt;A&gt;        | ForArrayK        |                     | ArrayKOf&lt;A&gt;        |
 | Const<A, T>      | ForConst         | ConstPartial&lt;A&gt;     | ConstOf<A, T>      |
 | Either<L, R>     | ForEither        | EitherPartial<L>    | EitherOf<L, R>     |
 | Id&lt;A&gt;            | ForId            |                     | IdOf&lt;A&gt;            |
 | Ior<L, R>        | ForIor           | IorPartial<L>       | IorOf<L, R>        |
 | NonEmptyArray&lt;A&gt; | ForNonEmptyArray |                     | NonEmptyArrayOf&lt;A&gt; |
 | Option&lt;A&gt;        | ForOption        |                     | OptionOf&lt;A&gt;        |
 | Try&lt;A&gt;           | ForTry           |                     | TryOf&lt;A&gt;           |
 | Validated<E, A>  | ForValidated     | ValidatedPartial<E> | ValidatedOf<E, A>  |

### Casting and the ^ operator

 We have established a 1 to 1 relationship between `F<A>` and `Kind<ForF, A>`, but the compiler does not have a way to enforce it. Therefore, there are situations where operating with a HKT can return us a value of type `Kind<ForF, A>` instead of the `F<A>` type that we are expecting. Since we know our type is the only class extending `Kind<ForF, A>` we can do a force cast to obtain our concrete type.

 Bow types include a static method `fix` that does this. We can extend our `Xor` type above to have it:

```swift
extension Xor {
    static func fix(_ value: XorOf<Left, Right>) -> Xor<Left, Right> {
        return value as! Xor<Left, Right>
    }
}
```

 To simplify things even further, Bow has introduced the `^` postfix operator, that calls `fix` to avoid boilerplate. In our example:

```swift
postfix func ^<A, B>(_ value: XorOf<A, B>) -> Xor<A, B> {
    return Xor.fix(value)
}
```

 This operator can be used with any of the existing types in Bow and lets us chain method calls in a similar manner as we do with the `?.` operator. For instance, consider the `Either` type and its `map` combinator. `map` is defined to operate at the kind level, so an invocation to this combinator returns something of type `Kind`, instead of `Either`.

```swift
let either = Either<DivideError, Int>.right(2)
let toString = either.map { value in value.description } // toString is of type Kind<EitherPartial<DivideError>, String
```

 We can continue chaining methods to this value as long as they are defined for `Kind`, but if we would like to use some method specific for `Either`, the compiler does not know about the 1 to 1 correspondence we stablished for the types and we need to cast. We can use the fix method:

```swift
let fixedToString = Either.fix(toString) // fixedToString is of type Either<DivideError, String>
```

 Or we can use the operator to reduce boilerplate:

```swift
let fixedToString2 = toString^
```

 The operator becomes much more convenient when chaining methods. For instance, the `swap` method is defined in `Either` and not available in `Kind`; therefore, we need to cast:

```swift
let swapped = either.map { value in value.description }^.swap() // swapped is of type Either<String, DivideError>
```

## HKT support for existing types

 Previous sections have covered how to create a new type with HKT support. However, there are a number of types that are already created and probably outside our control. How do we add HKT support for them?

 Unfortunately, there is no way to do this out of the box using the mechanisms that Swift provides for extensions. The solution that we have adopted is to wrap the existing type into another type with HKT support, and delegate methods to the internal wrapped value.

 Thus, you can see some types in Bow that have a `K` at the end. This indicates the type is a wrapper over another type, adding HKT support. The following table summarizes some of the types that we have added this kind of support.

 | Bow type    | Defined in module | Original type | From library  |
 | ----------- | ----------------- | ------------- | ------------- |
 | ArrayK      | Bow               | Array         |               |
 | DictionaryK | Bow               | Dictionary    |               |
 | SetK        | Bow               | Set           |               |
 | FutureK     | BowBrightFutures  | Future        | BrightFutures |
 | MaybeK      | BowRx             | Maybe         | RxSwift       |
 | ObservableK | BowRx             | Observable    | RxSwift       |
 | SingleK     | BowRx             | Single        | RxSwift       |
