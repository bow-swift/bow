// nef:begin:header
/*
 layout: docs
 title: Rank-N polymorphism
 */
// nef:end
// nef:begin:hidden
import Bow
// nef:end
/*:
 # Rank-N polymorphism

 {:.intermediate}
 intermediate

 Swift does not support Rank-N polymorphism yet. However, Rank-N polymorphism unlocks some interesting patterns and techniques. For this reason, Bow provides some helper classes that allow you to emulate Rank-N polymorphism. This document introduces Rank-N polymorphism and Bow's alternative approach starting from the basics of closures.

 ## What is Rank-N polymorphism?

 Swift allows us to write generic functions: functions that abstract over what specific types they operate on.
*/
func singletonArray<T>(_ v: T) -> [T] {
    [v]
}
/*:
 Here `singletonArray` is a function that can operate on any type we want. Specifically, the caller of the function decides what type to pass to the function.

 We say that such a function is *polymorphic* over the *type parameter* `T`, or alternatively that the function is *generic* over the type parameter `T`. Notice that we don't refer to `T` as a type. `T` is more like a placeholder for a type that will be determined when the function is called.

 Imagine we want to write a function `callTwice` that is generic over two type parameter `A` and `B` and accepts our `singletonArray` above as a parameter. Our function `callTwice` will execute the polymorphic function we pass to it with a value of type `A` and a second time with a value of type `B`. We need to express that `callTwice` takes a parameter that is a function polymorphic on a type parameter `T`. The function could look something like this:
 ```
 func callTwice<A, B>(_ f: <T>(T) -> [T], _ a: A, _ b: B) -> ([A], [B]) {
     (f(a), f(b)) // `f` really needs to be polymorphic, because we call it twice with inputs of different types.
 }
 ```
 Notice that we included `<T>` in front of the type signature of the parameter of our function `callTwice`. With this, we want to express that the parameter `f` must be a function polymorphic over one type parameter we called `T`. This is a made up syntax, don't try to write this in your Swift program because it won't compile.

 If we could write such a function, we could pass our `singletonArray` function to it, along with a value of any type we want:
 ```
 let a = callTwice(singletonArray, 0, "a") // == ([0], ["a"])
 let b = callTwice(singletonArray, "b1", "b2") // == (["b1"], ["b2"])
 let c = callTwice(singletonArray, "c", [0]) // == (["c"], [[0]])
 ```
 Notice how at each call of `callTwice` we are passing a value of different type, yet we always pass the same function `singletonArray` which is called with each type with a value of different type. With the syntax we made up, this is possible because we are able to say that the function we pass to `callTwice` must be a polymorphic function, in other words a function that can work with inputs of any type.

 The reason we needed to use a made up syntax for this example is because Swift doesn't allow us to write a function that requires a polymorphic function as a parameter. This feature is called *Rank-N polymorphism* and it's supported on some languages like Haskell.

 In the following sections we develop a technique to simulate Rank-N polymorphism. We start by reviewing the basics of closures. We then provide an alternative but equivalent way to encode closures that we will be able to generalise into something that approaches Rank-N polymorphism.

 ## The basics of closures
 Swift supports higher-order functions, which means that we can pass a function as an argument to another function or return a function as the result of another function. Furthermore, we can define *closures* which are functions that capture some data from its environment.

 For example, the function `randomWordGenerator` below returns a random word of length `n`. As you can see `n` is a random number that is generated once each time you execute this program. `randomWordGenerator` captures the value of `n`, which means that the strings returned by `randomWordGenerator` will all have the same length during the execution of the program. Each time you call `randomWordGenerator` you will get a different word, but all of them will have the same length. If you re-run the program a second time, `n` will probably get a different value and the length of the words returned by `randomWordGenerator` will be different.
*/
let n: Int = .random(in: 0 ..< 10)
let randomWordGenerator: () -> String = { 
    (0 ..< n).forEach { _ in 
        .random(in: "a" ... "z") 
    }
}
/*:
 In the example above we only got one `randomWordGenerator` function per program execution: if we want a different `randomWordGenerator` function with a different `n` we need to re-run the program. Let's create a function that returns a different `randomWordGenerator` function each time we call it. This is an example of a higher-order function, since it returns another function.
 */
func makeRandomWordGenerator() -> () -> String {
    let length: Int = .random(in: 0 ..< 10)
    return { 
        (0 ..< length).forEach { _ in 
            .random(in: "a" ... "z") 
        }
    }
}
/*:
 The body of `makeRandomWordGenerator` is basically the same code we had before (we renamed `n` to `length` to stress the fact that `makeRandomWordGenerator` doesn't use any variables from outside its body). But now, each time we call `makeRandomWordGenerator` a different `length` is generated, and thus we get a different `randomWordGenerator` function each time.

 We check this by creating 3 different functions with `makeRandomWordGenerator` and generating one word with each. We should see that each function prints words of different length (unless we are a bit unlucky).
 */
for _ in 0 ..< 3 {
    let f = makeRandomWordGenerator()
    print(f())
}
/*:
 An important thing to realise is that we cannot just generate the random `length` value inside the body of the closure returned from `makeRandomWordGenerator`. If we did so, a `randomWordGenerator` would return strings of different length each time we call it, and this is not what we want. We want each `randomWordGenerator` function to always return strings of the same length.

 This little example demonstrates that closures indeed capture values from their environment. Since we define `length` inside `makeRandomWordGenerator`,
 there's no way it can be accessed from outside its body. This means that the closures returned from `makeRandomWordGenerator` indeed carry a copy of `length` with them, because otherwise they couldn't know what length the words they generate are supposed to be.

 ## What exactly is a closure?
 Now, imagine for a moment that Swift doesn't allow closures to capture values from their environment. Now we can't just simply pass our `randomWordGenerator` functions around, because they cannot carry the value for `length` they need. Is there any way we can achieve a similar behaviour?

 Well, if we have our function inside a struct, it can access all the members of the struct, just like our `randomWordGenerator` body accessed the variable `length`.
 */
struct RandomWordGenerator {
    let length: Int

    func callAsFunction() -> String {
        (0 ..< length).forEach { _ in 
            .random(in: "a" ... "z")
        }
    }
}
/*:
*/
let anotherRandomWordGenerator = RandomWordGenerator(length: 6)
/*:
 Since Swift 5.2, because we called the function in our struct `callAsFunction` we are able to call an instance of our struct as it were a function:
 */
print(anotherRandomWordGenerator())
/*:
 And we can obviously pass a value of `RandomWordGenerator` around, which will always hold the `length` variable it needs. So we see that our struct behaves very much like a closure. Indeed, when the Swift compiler finds a closure definition in your code, it creates something similar to this struct under the hood.

 ## Generic closures

 Recall the `singletonArray` function we defined earlier:
 ```
 func singletonArray<T>(_ v: T) -> [T] {
     [v]
 }
 ```
 Can we write this function as a struct, like we explained in the previous section? Sure thing!
 ```
 struct SingletonArrayFunction {
     func callAsFunction<T>(_ v: T) -> [T] {
         [v]
     }
 }
 ```
 */
/*:
 We just expressed a polymorphic function as a struct!

 Recall the function `callTwice` we defined earlier with our made up syntax:
 ```
 func callTwice<A, B>(_ f: <T>(T) -> [T], _ a: A, _ b: B) -> ([A], [B]) {
     (f(a), f(b))
 }
 ```
 Now that we have expressed a polymorphic function as a struct, can we express this function with valid Swift syntax? Maybe something like this?
 ```
 func callTwice<A, B>(_ f: SingletonArrayFunction, _ a: A, _ b: B) -> ([A], [B]) {
     (f(a), f(b))
 }
 ```
 */
/*:
 Well, now we can only pass a value of `SingletonArrayFunction`, which is to say that we can only pass one specific function. This is not what we wanted, we wanted to be able to pass any polymorphic function with this signature `<T>(T) -> [T]`. We must find another way.

 ## Introducing FunctionK

 `FunctionK` is a class found in Bow that represents any polymorphic function. `FunctionK` takes two type parameters that represent type constructors. Specifically, `FunctionK` represents functions from `Kind<F, T>` to `Kind<G, T>` that is polymorphic on `T`, or expressed with the made up notation we introduced earlier: `<T>Kind<F, T> -> Kind<G, T>`.

 Specific functions are expressed as a subclass of `FunctionK`. Thus, if we have a function `f` that takes a parameter of type `FunctionK<F, G>`, we can to `f` any function from `Kind<F, T>` to `Kind<G, T>` that is polymorphic. Subclasses of `FunctionK` only need to override the generic method `invoke`, which represents the actual body of our function. `callAsFunction` is implemented automatically, so we can always call a `FunctionK` as it was a regular function.

 Our `SingletonArrayFunction` defined earlier can be seen as a `FunctionK<ForId, ForArrayK>.`
 */
final class SingletonArrayFunction: FunctionK<ForId, ForArrayK> {
    override func invoke<A>(_ fa: IdOf<A>) -> ArrayKOf<A> {
        ArrayK([fa^.value])
    }
}
/*:
 Now we can express our `callTwice` function with regular Swift syntax:
 */
func callTwice<A, B>(_ f: FunctionK<ForId, ForArrayK>, _ a: A, _ b: B) -> ([A], [B]) {
    (f(Id(a)).asArray, f(Id(b)).asArray)
}
