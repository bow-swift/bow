---
layout: docs
title: Concurrency
permalink: /docs/effects/concurrency/
---

# Concurrency
 
 {:.intermediate}
 intermediate
 
 `IO` is a data type that suspends side effects and provides support to work with them in an asynchronous and concurrent manner. This section explores the utilites that it offers to facilitate this task.
 
## Switching execution context
 
 Oftentimes we need to perform certain tasks on a background thread in order not to block the main thread, whose intended use is rendering the user interface. This is usually done with the Grand Central Dispatch, and, in particular, with the `DispatchQueue`.
 
 The main issue is that the API of `DispatchQueue` is difficult to compose. `IO` provides utilites to switch to a different queue and continue chaining computations with the `continueOn` method from the `Async` type class.

```swift
let program: IO<Never, Void> =
    DispatchQueue.main.shift()
        .followedBy(ConsoleIO.print("Hello from the main queue"))
        .continueOn(.global(qos: .background))
        .followedBy(ConsoleIO.print("Hello from the background queue"))
        .continueOn(DispatchQueue(label: "my-queue"))
        .followedBy(ConsoleIO.print("Hello from my custom queue"))^
```

## Running computations in parallel
 
 `IO` lets us run several independent computations using `zip`. However, this method won't run them in parallel. To achieve this behavior, there is a method called `parZip`, from the `Concurrent` type class.
 
 For example, we may have a function to fetch the HTML code from a website:

```swift
func fetchHTML(from url: URL) -> IO<Error, String>
```

 Using `parZip` we can fetch all three in parallel and get their results in a tuple:

```swift
let result: IO<Error, (String, String, String)> =
    IO.parZip(fetchHTML(from: URL(string: "https://bow-swift.io")!),
              fetchHTML(from: URL(string: "https:www.apple.com")!),
              fetchHTML(from: URL(string: "https://github.com")!))^
```

 The `parZip` method is overloaded to work from 2 to 9 parameters. If, instead of getting a tuple, you want to do some transformation to the data that you are receiving, you can use the `parMap` function from the `Concurrent` type class. In our previous example, we may want to create an array of values with the HTML contents of all the requests:

```swift
let result2: IO<Error, [String]> =
    IO.parMap(fetchHTML(from: URL(string: "https://bow-swift.io")!),
              fetchHTML(from: URL(string: "https:www.apple.com")!),
              fetchHTML(from: URL(string: "https://github.com")!)) { bow, apple, github in
                [bow, apple, github]
    }^
```

## Monad comprehensions
 
 The operations above play nicely with Monad comprehensions. You can easily change to a different `DispatchQueue` using the `continueOn` function and run computations in parallel using the `parallel` function. You can also assign tuples and get destructuring of each of their components.
 
 For instance, we can fetch the three previous websites in parallel in a background queue and then print their number of characters sequentially in the main queue:

```swift
let bow = IO<Error, String>.var()
let apple = IO<Error, String>.var()
let github = IO<Error, String>.var()

let websites = binding(
    continueOn(.global(qos: .background)),
    (bow, apple, github) <- parallel(fetchHTML(from: URL(string: "https://bow-swift.io")!),
                                     fetchHTML(from: URL(string: "https:www.apple.com")!),
                                     fetchHTML(from: URL(string: "https://github.com")!)),
    continueOn(.main),
    |<-ConsoleIO.print("Bow has \(bow.get.count) characters"),
    |<-ConsoleIO.print("Apple has \(apple.get.count) characters"),
    |<-ConsoleIO.print("GitHub has \(github.get.count) characters"),
    yield: ()
)
```

 For further information about how Monad comprehensions work in Bow, please refer to its documentation page.
