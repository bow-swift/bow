---
layout: docs
title: Functions vs. Procedures
permalink: /docs/fp-concepts/functions-vs-procedures/
---

# Functions vs. Procedures

 {:.beginner}
 beginner
 
 According to Wikipedia, **Functional Programming** is a programming paradigm - a style of building the structure and elements of computer programs - that treats computation as the evaluation of mathematical functions and avoids changing state and mutable data. In short, we can say that Functional Programming is programming with **functions**.

 Functions, as they are understood in FP, must have the following properties:

 - **Total**: functions must provide an output for every input.
 - **Deterministic**: for a given input, the function always returns the same output.
 - **Pure**: the evaluation of the function does not cause any other effects besides computing the output.

 We can notice that this does not totally match with the definition of functions (or methods) as entities declared in Swift using the `func` keyword, as the language does not enforce any of the previous properties when we are creating our functions. When we create a function that does not match any of the following properties stated above, we can refer to it as a **procedure**. Sometimes you can also read them as **pure functions** (matching the 3 properties above) versus **impure functions** (procedures).

 Let us look at the following code:

```swift
func add(x: Int, y: Int) -> Int {
    return x + y
}
```

 The function `add` is:
 - Total: given any input, it always provides an output.
 - Deterministic: for any given input, it always returns the same output.
 - Pure: the evaluation of the function does nothing else besides computing the sum of the two arguments.

 We can also see some examples where these properties are not fulfilled.

### Total vs. Partial

 Consider the following function:

```swift
func divide(x: Int, y: Int) -> Int {
    guard y != 0 else { fatalError("Division by 0") }
    return x / y
}
```

 Looking at its signature, ignoring the implementation, it says that given two `Int` values, it will provide another `Int`. However, this is not true: if the second argument is 0, there is no way to provide a valid output; actually, the implementation of this function causes a crash, as it is not able to provide a result. Therefore, `divide` is not **total**. The opposite of a total function is a **partial function**; i.e. it is not defined for every possible input.

### Deterministic vs. Non-Deterministic

 Now consider the following function:

```swift
func dice(withSides sides: UInt32) -> UInt32 {
    return 1 + arc4random_uniform(sides)
}
```

 From its signature, it says it will give us an unsigned integer of 32 bits for every value of the same type that we provide. This function is total; it is defined for every possible input. However, two invocations with the same input will (most likely) yield different values, as the output is randomized. This means the function is **non-deterministic**.

### Pure vs. Impure

 Finally, let us look at the following function:

```swift
func save(data: String) -> Bool {
    print("Saving data: \(data)")
    return true
}
```

 We can see the function is total (defined for every input) and deterministic (always returns the same value for a given input). However, the execution of the function does something observable from the outside besides computing the output: it prints a message to the standard output. This makes this function **impure**.

## Referential transparency

 If a function is total, deterministic and pure, it has a property called **referential transparency**. An expression is referentially transparent if it can be replaced by the result of its evaluation and the behavior of the program does not change. This enables local equational reasoning. For instance, using the `add` function defined above, we can square the sum of two values:

```swift
let square = add(x: 2, y: 5) * add(x: 2, y: 5)
```

 Since `add` is referentially transparent, we can replace calls to this function by the output it produces and the behavior of the program is not altered. This is known as common subexpression elimination.

```swift
let sum = add(x: 2, y: 5)
let square2 = sum * sum
```

 Notice that this is not necessarily the case when we have impure functions. Consider the following implementation of an impure `add` that logs the parameters it receives:

```swift
func impureAdd(x: Int, y: Int) -> Int {
    print("Received (\(x), \(y))")
    return x + y
}

let impureSquare = impureAdd(x: 2, y: 5) * impureAdd(x: 2, y: 5)
```

 If we apply the same technique as above to eliminate the common subexpressions:

```swift
let impureSum = impureAdd(x: 2, y: 5)
let impureSquare2 = impureSum * impureSum
```

 The result of the two operations is the same, but the observed behavior of the overall program is not the same: the first implementation prints twice to the console, as there are two invocations to `impureAdd`, whereas in the second case there is only one print when the sum is saved in `impureSum`.

 Referential transparency lets us have a better reasoning of our programs as we do not have to keep in mind the state of the computation and consider any side effects happening after the execution of a certain piece of code. Moreover, code that is referentially transparent is intrinsically testable (we just need to provide inputs and assert over the expected outputs) and can be optimized and parallelized easily (there is no shared mutable state that causes concurrency issues).

## Memoization

 Another consequence of having a function that is referentially transparent is that it can be **memoized**. Memoization is a technique used to cache already computed values, specially if they have a high cost to be computed. When a function is memoized, you can think of it as a lookup table where inputs and their corresponding outputs are saved. Subsequent invocations just retrieve the value from the table instead of actually computing it.

 Bow has utilities to memoize functions easily:

```swift
func length(_ input: String) -> Int {
    // Let's assume this is a long running operation
    return input.count
}

let memoizedLength = memoize(length)
let length1 = memoizedLength("Hello, world!")
let length2 = memoizedLength("Hello, world!")
```

 First call to obtain `length1` will actually compute it and save the result in an internal lookup table. Second call to obtain `length2` will retrieve the value that was previously computed.

 In cases where we have recursive functions, memoization is slightly different, as we need the memoized function inside the function body. For instance, implementing a memoized factorial can be done like:

```swift
let memoizedFactorial: (Int) -> Int = memoize { factorial, x in
    x == 0 ? 1 : x * factorial(x - 1)
}

let fact7 = memoizedFactorial(7)
let fact4 = memoizedFactorial(4)
let fact9 = memoizedFactorial(9)
```

 In this case, computing the factorial of 7 also saves any intermediate steps to compute its value, so when we ask for the factorial of 4, it is already in the lookup table. Finally, asking for factorial of 9 starts computing and stops when it needs to compute factorial of 7, which was already computed above.

## Function composition

 Referentially transparent functions are the building blocks for our programs, but we need some operation to combine them. The essential operation for functions is function composition. Bow provides functionality to compose two functions easily.

```swift
func f1(_ x: Int) -> Int {
    return 2 * x
}

func f2(_ x: Int) -> String {
    return "\(x)"
}

let composed1 = compose(f2, f1)
let composed2 = f2 <<< f1
```

 Both the `compose` function and the `<<<` operator receive two functions and provide a new function which behaves like applying both functions sequentially. `f2 <<< f1` is read as *f2 after f1*; that is, in the resulting function, `f1` is applied to the input and its output is then fed to `f2`.

 In some cases, `compose` can be difficult to read right to left, or simply is not convenient to use. For those cases, Bow has utility functions that reverse the order of the arguments.

```swift
let composed3 = andThen(f1, f2)
let composed4 = f1 >>> f2
```

 Those calls are equivalent to the ones above, but with arguments reversed. `f1 >>> f2` is read as *apply f1 and then f2*, and the behavior is exactly the same as in the `<<<` operator.

 Composition of functions is associative; i.e. the following functions are equivalent:

```swift
func f3(_ x: String) -> String {
    return String(x.reversed())
}

let associativity1 = (f3 <<< f2) <<< f1
let associativity2 = f3 <<< (f2 <<< f1)
```

 Given three functions, it does not matter if we compose the first two, and then the third one, or the latter two and then the first one. There is also a function that, when composed with any other function, does nothing: the `id` (identity) function, which is included in Bow.

```swift
let identity1 = f1 <<< id
let identity2 = id <<< f1
```

 The functions above have the exact same behavior as `f1`.

## Working with impure functions

 Real world software rarely has functions as nicely written as the `add` function above. We usually have to deal with partial, non-deterministic and/or impure functions, since software has to deal with errors and perform side effects in order to be useful. Besides presenting issues breaking referential transparency, function composition cannot be done in these circumstances. How can we deal with such situations?

 Bow provides numerous data types that can be used to model different effects in our functions. Using those data types, such as `Option`, `Either` or `IO` can help us transform partial, non-deterministic or impure functions into total, deterministic and pure ones. Once we have them, we can use combinators that will help us compose those functions nicely.
