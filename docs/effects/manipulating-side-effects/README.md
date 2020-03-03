---
layout: docs
title: Manipulating side effects
permalink: /docs/effects/manipulating-side-effects/
---

# Manipulating side effects
 
 {:.beginner}
 beginner
 
 Once effects have been suspended in an `IO` data type, we can use different combinators to manipulate the enclosed data. This section explores the different operations that we can perform over one or several `IO` values.
 
## Transforming data
 
 An `IO<E, A>` value describes a computation that will eventually produce a value of type `A` or cause an error of type `E`. For instance, if we want to retrieve data from a network request using the extensions that Bow Effects adds over `URLSession`, we would get an `IO<Error, (URLResponse, Data)>`:

```swift
let request: IO<Error, (response: URLResponse, data: Data)> = URLSession.shared.dataTaskIO(with: URL(string: "https://bow-swift.io")!)
```

 However, what we would need is, instead of `Data`, the `String` representation of such data. We could be tempted to run the computation, extract the `Data` and start manipulating it. However, this will not be too different from running the non-functional version of `URLSession.dataTask`, as we would be performing side effects.
 
 Our goal is to keep side effects suspended and only run them *at the edge of the world*; that is, in the outer layers of our application where we have them all under control. Then, how can we manipulate the values wrapped in an `IO`?
 
 The answer is a combinator that you have probably seen in several other data types: the `map` combinator. `IO` has an instance of `Functor`; therefore, `map` is available to be used. In our example, we can perform a `map` to obtain the `Data` out of the tuple, and sequence another `map` to convert it to a `String`:

```swift
let stringIO: IO<Error, String> =
    request.map { result in result.data }
           .map { data in String(data: data, encoding: .utf8) ?? "" }^
```

## Combining independent computations
 
 We can wrap the previous operation into a function that fetches the HTML code of a website:

```swift
func fetchHTML(from url: URL) -> IO<Error, String> {
    return URLSession.shared.dataTaskIO(with: url)
        .map { result in result.data }
        .map { data in String(data: data, encoding: .utf8) ?? "" }^
}
```

 Let's say that now we need to fetch the HTML code from multiple URLs. Each fetching operation is independent from each other. How can we run multiple `IO` operations that are independent? The answer is the `zip` combinator, present in `Applicative`. This combinator performs the different `IO` operations and returns a single `IO` that tuples the results:

```swift
let html: IO<Error, (String, String, String)> =
    IO.zip(fetchHTML(from: URL(string: "https://bow-swift.io")!),
           fetchHTML(from: URL(string: "https://www.apple.com")!),
           fetchHTML(from: URL(string: "https://github.com")!))^
```

 The `zip` combinator is overloaded to work from 2 to 9 operations. If any of the operations above fails, the failure is reported. If all succeed, the tuple with the three results is returned. Note that even though the computations are run independently, that does not mean they are run concurrently. This is possible with `IO` though, and you can find more information about it in the **Concurrent and Asynchronous execution** section.
 
 If you want to combine the results of the independent computations, `IO` also provides a `map` function that accepts a closure at the end to combine the results. For instance, instead of tupling the three results, we may want to wrap them in an array:

```swift
let html2 = IO<Error, [String]>.map(
    fetchHTML(from: URL(string: "https://bow-swift.io")!),
    fetchHTML(from: URL(string: "https://www.apple.com")!),
    fetchHTML(from: URL(string: "https://github.com")!)) { bow, apple, github in
        [bow, apple, github]
    }^
```

 As with `zip`, `map` is overloaded to work from 2 to 9 parameters and will provide an error if any of the operations fails. It does not run the computations concurrently, but it has a counterpart that does it.
 
## Sequencing dependent computations
 
 So far, we have been able to run `IO` computations that do not depend on each other. But how can we chain `IO` computations that need to use the output of other computations? In our running example, let's say that we want to print to the standard output a message with the length of the HTML that we have fetched. Fetching HTML and printing are 2 side-effectful operations, but printing the log needs the result of fetching HTML; therefore, there is a dependency between them.
 
 In order to chain dependent computations, `IO` provides a method that you may already be familiar with from other types: the `flatMap` combinator. This combinator is part of `Monad` and `IO` has an instance for it.
 
 Therefore, we can pass the fetched HTML code to the print function using:

```swift
let program: IO<Error, Void> = fetchHTML(from: URL(string: "https://bow-swift.io")!).flatMap { html in
    ConsoleIO.print("Received \(html.count) characters.")
}^
```

 We can also print something before starting to fetch the HTML code:

```swift
let program2: IO<Error, Void> = ConsoleIO.print("Fetching Bow's main page").flatMap { _ in
    fetchHTML(from: URL(string: "https://bow-swift.io")!).flatMap { html in
        ConsoleIO.print("Received \(html.count) characters.")
    }
}^
```

 This program chains different `IO` computations that are dependent from each other and need to happen in a specific order. However there is an improvement that we can do to it using some utility function based on `flatMap`.
 
 The first one is the usage of the function `followedBy`. This function lets us sequence 2 effects, where the second one needs to happen after the first, but does not need the output of the first. That is the kind of dependency we have between our first `print` and the fetch operation: they need to happen in that order, but `fetchHTML` does not consume anything produced from the `print`. You can notice it above since the wildcard `_` is used in the first `flatMap` operation.

```swift
let program3: IO<Error, Void> = ConsoleIO.print("Fetching Bow's main page").followedBy(
    fetchHTML(from: URL(string:"https://bow-swift.io")!)).flatMap { html in
        ConsoleIO.print("Received \(html.count) characters.")
    }^
```

### Monad comprehensions
 
 Chaining computations is possible thanks to `flatMap` but it can become cumbersome quickly as the nesting of `flatMap` quickly becomes difficult to read. To solve this issue, Bow provides **Monad comprehensions**, that you can read more about in its dedicated section.
 
 In summary, Monad comprehensions provide a better syntax in imperative-like style to chain computations. The program above can be rewritten as:

```swift
let htmlCode = IO<Error, String>.var()

let program4: IO<Error, Void> = binding(
             |<-ConsoleIO.print("Fetching Bow's main page"),
    htmlCode <- fetchHTML(from: URL(string: "https://bow-swift.io")!),
             |<-ConsoleIO.print("Received \(htmlCode.get.count) characters."),
    yield: ()
)^
```

 This syntax enables an easier way to compose different computations and is simpler to read and maintain.
