---
layout: docs
title: Suspending side effects
permalink: /docs/effects/suspending-side-effects/
---

# Suspending side effects
 
 {:.beginner}
 beginner
 
 In Functional Programming, functions must honor its mathematical definition: they must be total, deterministic and pure. However, this is not the situation in many cases; in fact, programs are useful when side-effects happen. The issue is not having side-effects *per se*, but the moment and the circumstances when they are executed. If they happen in the moment we invoke them, reasoning about their outcome becomes much more difficult. In addition to that, composition becomes harder, if not impossible, to achieve.
 
## Motivation
 
 Consider the following two functions:

```swift
func greet(name: String) {
    print("Hello \(name)!")
}

func homePage(callback: @escaping (Either<Error, Data>) -> ()) {
    if let url = URL(string: "https://bow-swift.io") {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                callback(.right(data))
            } else if let error = error {
                callback(.left(error))
            }
        }.resume()
    }
}
```

 Function `greet` has a side effect (printing to the console) and does not produce any value, making it harder to compose this function with any other function. Function `homePage` does produce values, but they are returned through a callback as it is an asynchronous operation, making it difficult to be composed as well, besides having another side effect (network call).
 
## Creating an IO from a synchronous call
 
 Dealing with this type of functions is usual in our programming routine, either because we have some non-functional legacy code or because we are using libraries that do not provide a functional API. What can we do to overcome this issue?
 
 Bow Effects provides the IO data type. It is a data type that lets us suspend the execution of side effects, providing us a value that describes the side effect, but it has not been performed yet. That way, we can convert our programs into values that we can combine and compose.
 
 `IO` has a method called `invoke` that can help us suspend a side effect. For instance, the `greet` function above can be rewritten as:

```swift
func greetIO(name: String) -> IO<Never, Void> {
    return IO.invoke { greet(name: name) }
}
```

 It may seem like we haven't done much, as we are still calling the old function, but its execution is deferred. It has been wrapped in an `IO` value that cannot produce errors (the `Never` type) and that do not produce any value (the `Void` type). Function `greetIO` is pure and provides a value as its output that can be composed with other `IO` values to make a bigger program.
 
 We can also wrap functions throwing errors in an IO using `invoke`. The function `findUser(by:)` below is impure:

```swift
func findUser(by id: String) throws -> User {
    guard exists(id: id) else {
        throw DatabaseError.missing(id: id)
    }
    return fetch(id: id)
}
```

 Its pure counterpart can be written as:

```swift
// Making use of the impure version
func findUserIO(by id: String) -> IO<DatabaseError, User> {
    return IO.invoke { try findUser(by: id) }
}

// Writing a new pure version
func findUser_fromEither(by id: String) -> IO<DatabaseError, User> {
    return IO.invokeEither {
        guard exists(id: id) else {
            return .left(.missing(id: id))
        }
        return .right(fetch(id: id))
    }
}
```

 The functional versions above have an additional benefit: they are explicit about the type of the errors that may happen during their execution.
 
 Besides `invoke`, `IO` has other methods to create a suspended side effect, like the `invokeEither` above, `invokeResult`, `invokeValidated` and `invokeTry`.
 
## Creating an IO from an asynchronous call
 
 Let's look now at the `homePage` function. It provides a generic (non-typed) error or a `Data` value, but it does it through a callback. How can an asynchronous call be suspended into an `IO` value?
 
 `IO` has a method called `async` that serves to this purpose:

```swift
func homePageIO() -> IO<Error, Data> {
    return IO.async { callback in
        if let url = URL(string: "https://bow-swift.io") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    callback(.right(data))
                } else if let error = error {
                    callback(.left(error))
                }
            }.resume()
        }
    }^
}
```

 This new function provides an `IO<Error, Data>` value that suspend this asynchronous call and that can be transformed or composed.
 
 {:.intermediate}
 intermediate
 
## Creating an IO that depends on a context
 
 So far we have seen how to create an `IO` suspending a side effect. There are other cases where we may be interested on creating an `IO` that depends on a context that we still do not have.
 
 To this purpose, Bow Effects provides the `EnvIO<D, E, A>` type, which models an `IO<E, A>` that depends on some context `D`. This type is useful to have a sort of dependency injection, where we can write our programs without worrying too much about where the context is coming from, and later, when we can provide such context, we run the program.
 
 For instance, consider the following services: a network API to fetch users by their id and a database to save the user.

```swift
protocol API {
    func getUser(by id: String) -> IO<Error, User>
    // ... Other methods ...
}

protocol Database {
    func save(user: User) -> IO<Error, Void>
    // ... Other methods ...
}
```

 We can create an Environment that provides these abstractions:

```swift
struct Environment {
    let database: Database
    let api: API
}
```

 Now, let's say that we want to implement a function that gets a user from the API and stores it in the database. We can create an `EnvIO` that depends on the `Environment` that we created above to get the `API` and `Database`:

```swift
func cacheUser(by id: String) -> EnvIO<Environment, Error, ()> {
    return EnvIO { environment in
        environment.api.getUser(by: id)
            .flatMap { user in environment.database.save(user: user) }
    }
}
```

 This will allow us to run the program that we have created under different environments; e.g. we can provide different implementations for production and testing:

```swift
// Providing production implementations
let prodEnv = Environment(database: ProductionDatabase(),
                          api: ProductionAPI())
cacheUser(by: "12345").provide(prodEnv)

// Providing testing implementations
let testEnv = Environment(database: TestDatabase(),
                          api: TestAPI())
cacheUser(by: "12345").provide(testEnv)
```
