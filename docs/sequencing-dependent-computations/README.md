---
layout: docs
title: Sequencing dependent computations
permalink: /docs/composition/sequencing-dependent-computations/
---

# Sequencing dependent computations
 
 {:.beginner}
 beginner
 
## Sequencing an effect that depends on another
 
#### Problem
 
 **I have**:
 
 - A value of type `F<A>`.
 - A function of type `(A) -> F<B>`.
 
 **I want to have**:
 
 - A value of type `F<B>`.
 
#### Solution
 
 In order to have a value of `F<B>` we need to run the provided function, but we need an input for it. This input may be obtained from `F<A>`, but the type does not match with the requirement of the function.
 
 Fortunately, we have the `flatMap` function, present in the [Monad type class](https://bow-swift.io/next/api-docs/Protocols/Monad.html). It will be able to access the internals of the effect, and feed the value to the provided function.
 
#### Example
 
 Consider the following value and function:

```swift
let conferenceOption = Option.some(Conference(title: "WWDC"))

// Provides the next talk for a Conference, if it exists.
func nextTalk(at conference: Conference) -> Option<Talk>
```

 The function `nextTalk` lets us retrieve the next talk for a given conference. However, we do not have a conference itself, but an `Option<Conference>`. We can use the `flatMap` operation to achieve our goal:

```swift
let talkOption = conferenceOption.flatMap { conference in
    nextTalk(at: conference)
}
```

## Sequencing two effects
 
#### Problem

 **I have**:
 
 - A value of type `F<A>`.
 - A value of type `F<B>`.
 
 **I want to have**:
 
 - A value of type `F<B>`, which should be run only if `F<A>` is successful.
 
#### Solution
 
 We could use the `flatMap` operation here by providing a function that ignores the input and yields the constant value of type `F<B>`. However, the [Monad type class](https://bow-swift.io/next/api-docs/Protocols/Monad.html) provides a convenience function called `followedBy` that takes a constant value instead of a function, and has the same semantics as `flatMap`.
 
#### Example
 
 This function can be useful when we want to apply an effect conditionally after successfully applying another one. An example of this could be printing a message to the console when another effect finishes successfully:

```swift
// Performs a network call, returning an error or the content of the response
func networkCall() -> IO<Error, String>
```

```swift
let program: IO<Error, Void> = networkCall()
    .followedBy(ConsoleIO.print("Finished successfully"))^
```

 This provides a single `IO<Error, Void>` that will print the message if the network call finishes successfully, and will not print anything in case the network call fails with an error.
 
## Sequencing two effects, keeping the result of the first
 
#### Problem
 
 **I have**:
 
 - A value of type `F<A>`.
 - A function of type `(A) -> F<B>`.
 
 **I want to have**:
 
 - A value of type `F<A>`, but performing the effect given by the function.
 
#### Solution
 
 The `followedBy` function does not let us access the results of the previous effect, or return it as a result. If we want to do that, the [Monad type class](https://bow-swift.io/next/api-docs/Protocols/Monad.html) provides the `flatTap` function. Its behavior is like `flatMap`, but disregarding the result of the second effect and keeping the first.
 
#### Example
 
 The `flatTap` operation is useful, for instance, to print some log messages. Using the previous network call example:

```swift
let loggedResponse: IO<Error, String> = networkCall()
    .flatTap { response in
        ConsoleIO.print("Response from call: \(response)")
    }^
```

 This way, the log is executed if the network call is successful, and still lets us chain other operations to work with its response.
