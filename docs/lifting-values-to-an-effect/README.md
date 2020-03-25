---
layout: docs
title: Lifting values to an effect
permalink: /docs/composition/lifting-values-to-an-effect/
---

# Lifting values to an effect
 
 {:.beginner}
 beginner
 
## Working with effectful types
 
#### Problem
 
 **I have**:
 
 - A value of type `A`.
 
 **I want to have**:
 
 - A value of type `F<A>`, where `F` is my *effect* type.
 
#### Solution
 
 We can use the `pure` function present in the [Applicative type class](https://bow-swift.io/next/api-docs/Protocols/Applicative.html) to embed a value into an effect.
 
#### Examples
 
 We can lift plain type values, like Int or String, into effect types, like `Option` or `ArrayK`, buy using `pure`:

```swift
Option.pure(3)^       // Returns Some(3)
ArrayK.pure("Hello")^ // Returns ArrayK(["Hello"])
```

 Notice that in the case of `ArrayK`, we only have a possibility to create an ArrayK with a single value with `pure`, but in the case of `Option`, there could have been two possible implementations: using `Option.some` and `Option.none`. As a rule of thumb, the implementation of `pure` will always lead to the successful case of the effect type.
 
 `pure` is also available for types that have more than one type parameter, like `Either`, but we will have to provide help on the type parameters, as the compiler cannot infer the left type argument from a single value:

```swift
Either<Int, String>.pure("Hello")^
```

 Note here that the type of the argument passed to `pure` must be the rightmost type argument in the effect type signature.
