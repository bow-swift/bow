---
layout: docs
title: Handling errors
permalink: /docs/effects/handling-errors/
---

# Handling errors
 
 {:.beginner}
 beginner
 
 `IO` provides explicit error handling capabilities by letting you specify the type of errors that it is able to capture. By doing this you are able to have better reasoning of what can go wrong and how to deal with that in a much more scoped manner. You can also choose not to worry about the type and resort to `Error` as a general way of capturing errors by using the `Task` type, or even work with `IO` values that will never produce an error using the `UIO` type.
 
## Raising errors
 
 You can raise an error inside an `IO` by using its `raiseError` method:

```swift
let networkError: IO<NetworkError, String> = IO.raiseError(.notFound)^
```

## Transforming errors
 
 Similar to transforming the data inside an `IO` using the `map` operator, you can transform the error type using `mapLeft`. This is useful to handle errors at different layers of your application. For instance, you may want to map a `NetworkError` to a `DomainError` when you move from your network layer to your domain layer:

```swift
let domainError: IO<DomainError, String> = networkError.mapLeft { error in
    switch error {
    case .notFound: return .missingUser
    // Map other cases
    }
}
```

## Handling errors

 `IO` provides mechanisms to recover from errors once they have potentially happened. One of the methods that it provides is the `handleError` method, which lets us provide a value as a response to the error that happened. For instance, we can provide a default value for a `notFound` error:

```swift
let defaultContent = "Default content"
let resolved: IO<NetworkError, String> = networkError.handleError { error in
    switch error {
    case .notFound: return defaultContent
    // Handle other cases
    }
}^
```

 Alternatively, we can provide a different computation to handle the potential errors (that may have its own errors). For instance, we can perform a network call and retry it in a different server it if fails:

```swift
func fetchData(from: URL) -> IO<NetworkError, String>
fetchData(from: URL(string: "http://my-server.com")!)
    .handleErrorWith { error in
        switch error {
        case .notFound: return fetchData(from: URL(string: "http://another-server.com")!)
        // Handle other cases
        }
    }
```
