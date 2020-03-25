---
layout: docs
title: Monad comprehensions
permalink: /docs/patterns/monad-comprehensions/
---

# Monad comprehensions
 
 {:.beginner}
 beginner
 
 Monad comprehensions are a generalization over the syntax provided in Swift to unwrap `Optional`s using `if let` or `guard let`, or to safely run throwing functions using `try?`. This page shows how Bow provides an uniform syntax to have direct, imperative-like style of working with monadic values.
 
## Motivation
 
 For instance, consider the following function receiving three optional values of types `Int`, `Double` and `String`. The purpose of the function is to unwrap the three values and make a `String` with the contents of all three, or return `nil` if any of them does not have a value. It can be implemented using the `if let` syntax to safely unwrap the optionals:

```swift
func join_ifLet(_ a: Int?, _ b: Double?, _ c: String?) -> String? {
    if let x = a,
       let y = b,
       let z = c {
        return "\(x), \(y), \(z)"
    }
    return nil
}
```

 This is equivalent to the following implementation:

```swift
func join_flatMap(_ a: Int?, _ b: Double?, _ c: String?) -> String? {
    return a.flatMap { x in
        b.flatMap { y in
            c.map { z in
                "\(x), \(y), \(z)"
            }
        }
    }
}
```

 The `if let` syntax is just a sugared version over nested `flatMap` operations that makes it more natural for an imperative way of writing code. However, consider now that, instead of `Optional` values, the function works with `Result` type. The `if let` syntax is not avaiable in that case, so the only option is to use `flatMap`:

```swift
func join_flatMap(_ a: Result<Int, Error>, _ b: Result<Double, Error>, _ c: Result<String, Error>) -> Result<String, Error> {
    return a.flatMap { x in
        b.flatMap { y in
            c.map { z in
                "\(x), \(y), \(z)"
            }
        }
    }
}
```

 As you can see, the implementation of the two functions is **exactly** the same. So, if the `if let` construction is equivalent to the flatMap version, why can't we use it with other types that have a `flatMap` operation?
 
## Monadic values
 
 The `if let` syntax is a particular case of a bigger pattern known as **Monad comprehensions**. Despite its name, it is a very simple idea. It lets us work with the potential values in monadic types without nesting `flatMap` calls. For now, when we refer to *monadic types*, it is enough to know that are types that conform to the `Monad` type class and therefore have a `map` and `flatMap` operation. Note that having those methods is not enough; `Monad` can only be implemented by types that have HKT simulation, so this does not work with Swift `Optional` and `Result` as they do not have HKT support.
 
 There are multiple types in the different modules in Bow that already implement `Monad`:
 
 | Module     | Types                        |
 | ---------- | ---------------------------- |
 | Bow        | Cokleisli, Function0, Function1, Kleisli, ArrayK, Either, Eval, Id, Ior, NonEmptyArray, Option, Try, EitherT, OptionT, StateT, WriterT       |
 | BowEffects | IO, Resource                 |
 | BowRx      | SingleK, MaybeK, ObservableK |
 | BowFree    | Free, Cofree                 |
 
 This means that, for any of these types, you can use monad comprehensions.
 
## Bindings
 
 So far, we know what types provide support for monad comprehensions. In this section, we are going through how monad comprehensions look like in Bow.
 
 Revisiting the previous example, let's try to write it again using `Option` as a data type:

```swift
func join_comprehensions(_ a: Option<Int>, _ b: Option<Double>, _ c: Option<String>) -> Option<String> {
    // Create variables for binding
    let x = Option<Int>.var()
    let y = Option<Double>.var()
    let z = Option<String>.var()
    
    // Operate over the contents of an Option in direct syntax
    return binding(
        x <- a,
        y <- b,
        z <- c,
        yield: "\(x.get), \(y.get), \(z.get)"
    )^
}
```

 We can also write this function for the `Either` type:

```swift
func join_comprehensions(_ a: Either<Error, Int>, _ b: Either<Error, Double>, _ c: Either<Error, String>) -> Either<Error, String> {
    // Create variables for binding
    let x = Either<Error, Int>.var()
    let y = Either<Error, Double>.var()
    let z = Either<Error, String>.var()
    
    // Operate over the contents of an Either in direct syntax
    return binding(
        x <- a,
        y <- b,
        z <- c,
        yield: "\(x.get), \(y.get), \(z.get)"
    )^
}
```

 Or even for `ArrayK`:

```swift
func join_comprehensions(_ a: ArrayK<Int>, _ b: ArrayK<Double>, _ c: ArrayK<String>) -> ArrayK<String> {
    // Create variables for binding
    let x = ArrayK<Int>.var()
    let y = ArrayK<Double>.var()
    let z = ArrayK<String>.var()
    
    // Operate over the contents of an ArrayK in direct syntax
    return binding(
        x <- a,
        y <- b,
        z <- c,
        yield: "\(x.get), \(y.get), \(z.get)"
    )^
}
```

 Looking at the implementation of each function, we can see a similar structure in each of them. We will try to break it down and explain each part involved in a monad comprehension.
 
### Variables for binding
 
 Variables that will be assigned in the monad comprehension need to be created before running it. This is a limitation over the `if let` syntax, but it is the best we can get at the moment. In order to create a variable, you can use the `var` method:

```swift
let x = Option<Int>.var()           // A variable of type Int that works on comprehensions on Option<_>
let y = Either<Error, Double>.var() // A variable of type Double that works on comprehensions on Either<Error, _>
let z = ArrayK<String>.var()        // A variable of type String that works on comprehensions on ArrayK<_>
```

 In order to work with monad comprehensions, all variables have to work on the same type; i.e. you cannot mix Option and Either in the same comprehension. Also, you cannot mix, for instance, `Either<Error, _>` and `Either<String, _>`. They are two different monadic contexts that cannot compose with each other.
 
 Variables can hold a value of a type. This value can be retrieved in the comprehension using `x.get` after it has been bound to a value.
 
 **Important:** Trying to access a variable that does not have a bound value will cause a fatal error.
 
### Binding expressions
 
 Once that we have created variables, we can assign them using the `<-` operator. This operator lets us assign a value from a monadic context in a similar way as we would do it using the assignment operator `=`. The left side of the operator must be a variable, created as explained above. The right side of the operator must be a value in a monadic context.
 
 For instance, for the variables `x`, `y` and `z` created above, we could write binding expressions like:

```swift
x <- Option.some(1)
y <- Either<Error, Double>.right(.pi)
z <- ArrayK("A", "B", "C")
```

 Or we could assign them to the output of a function:

```swift
func parse(_ str: String) -> Option<Int> {
    return Int(str).toOption()
}

x <- parse("1")
```

 In the expression above, `x` will contain the value `1`, and we won't need to worry about unwrapping it from the option.
 
### Sequencing operations
 
 Binding expressions do not do anything unless they are sequenced. To do so, they need to be invoked in a `binding` function. The `binding` function accepts any number of binding expressions and finishes with a `yield` parameter that provides the value that the monad comprehension will return.

```swift
let v1 = Option<Int>.var()
let v2 = Option<Int>.var()
let v3 = Option<Int>.var()

let result = binding(
    v1 <- Option.some(1), // v1 is bound to 1
    v2 <- Option.some(5), // v2 is bound to 5
    v3 <- Option.some(8), // v3 is bound to 8
    yield: v1.get + v2.get + v3.get // 1 + 5 + 8
) // result contains Option.some(14)
```

 If a binding expression cannot be bound to a value, because, for instance, it is bound to `Option.none`, `Either.left` or and empty `ArrayK`, the binding stops proceeding forward.

```swift
let nothing = binding(
    v1 <- Option.some(1), // v1 is bound to 1
    v2 <- Option.none(),  // v2 cannot be bound to a value
    v3 <- Option.some(8), // this is never bound as the previous step failed
    yield: v1.get + v2.get + v3.get
) // result contains Option.none()
```

### Ignoring the result
 
 Sometimes we may be interested in running a monadic effect but disregard its produced result. That is the case of printing something to the standard output; the value it produces is of type `Void`, so we do not need to assign it. We could still create a variable to do so, like:

```swift
let voidVar = IO<Error, Void>.var()
voidVar <- ConsoleIO.print("")
```

 But that boilerplate code can be avoided. Bow provides the prefix operator `|<-` to sequence a monadic effect and disregard its produced result. Thus, we can write a program to greet the user:

```swift
func write(_ line: String) -> IO<Error, Void> {
    return IO.invoke { print(line) }
}

func read() -> IO<Error, String> {
    return IO.invoke { "Tomás" } // Hardcoded value, it should call Swift.readLine
}

let name = IOPartial<Error>.var(String.self)

let program = binding(
         |<-write("What's your name?"),
    name <- read(),
         |<-write("Hello \(name.get)"),
    yield: ()
)
```

 The program above is equivalent to the following version using `flatMap`:

```swift
let program2 = write("What's your name?").flatMap { _ in
    read().flatMap { name in
        write("Hello \(name)")
    }
}
```

 Although the two versions are equivalent, the monad comprehension version is easier to read using direct syntax and avoiding the nested `flatMap` operations.
 
 {:.intermediate}
 intermediate
 
## Polymorphic monad comprehensions
 
 If we revisit the `join` function above, we can see that we have three implementations for `Option`, `Either` and `ArrayK` that are almost the same. The only difference between them is the input types and how the variables are created. The binding process is exactly the same code.
 
 This is not a coincidence and it is thanks to the use of the `Monad` abstraction. In fact, we can write a single function that is not aware of the types we want to invoke it with, as long as it has an instance of `Monad`:

```swift
func join<F: Monad>(_ a: Kind<F, Int>, _ b: Kind<F, Double>, _ c: Kind<F, String>) -> Kind<F, String> {
    // Create variables for binding
    let x = Kind<F, Int>.var()
    let y = Kind<F, Double>.var()
    let z = Kind<F, String>.var()
    
    // Operate over the contents of a monadic value in direct syntax
    return binding(
        x <- a,
        y <- b,
        z <- c,
        yield: "\(x.get), \(y.get), \(z.get)"
    )
}
```

 With this implementation, we can invoke the function using whatever monadic type we would like:

```swift
// Option<_>
join(Option.some(1), Option.some(.pi), Option.some("Hello")) // Option.some("1, 3.141592, Hello")

// Either<Error, _>
join(Either<Error, Int>.right(1), Either<Error, Double>.right(.pi), Either<Error, String>.right("Hello")) // Either.right("1, 3.141592, Hello")

// Id<_>
join(Id(1), Id(.pi), Id("Hello")) // Id("1, 3.141592, Hello")

// Ior<String, _>
join(Ior<String, Int>.right(1), Ior<String, Double>.right(.pi), Ior<String, String>.right("Hello")) // Ior.right("1, 3.141592, Hello")

// ArrayK<_>
join(ArrayK(1, 2, 3), ArrayK(Double.pi), ArrayK("Hello", "Bye")) // ArrayK("1, 3.141592, Hello",
                                                                 //        "1, 3.141592, Bye",
                                                                 //        "2, 3.141592, Hello",
                                                                 //        "2, 3.141592, Bye",
                                                                 //        "3, 3.141592, Hello",
                                                                 //        "3, 3.141592, Bye")
```
