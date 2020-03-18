// nef:begin:header
/*
 layout: docs
 title: Transforming data
 */
// nef:end
// nef:begin:hidden
import Bow
// nef:end
/*:
 # Transforming data
 
 {:.beginner}
 beginner
 
 ## Using a transforming function
 
 #### Problem
 
 **I have**:
 
 - A value of type `F<A>`.
 - A function `(A) -> B`.
 
 **I want to have**:
 
 - A value of type `F<B>`.
 
 #### Solution
 
 You can transform the inner type of an effect with the `map` function. Instead of unwrapping the value/s potentially wrapped in your effect type, you pass the function to `map` and it will be able to apply the transformation.
 
 `map` is available in the [Functor type class](https://bow-swift.io/next/api-docs/Protocols/Functor.html) and most of the types in Bow provide an instance for `Functor`.
 
 #### Example
 
 Consider we have a function to convert an Int to a String. We can use it to map over many different types, like Option or ArrayK:
 */
let toString: (Int) -> String = { n in "\(n)" }

Option.some(2).map(toString)^    // Returns Option.some("2")
ArrayK([1, 2, 3]).map(toString)^ // Returns ArrayK(["1", "2", "3"]
/*:
 If we `map` over an Option, it will transform the value contained in the `some` case; if we do it on ArrayK, it will transform each of the values in the array.
 
 We can map over an empty Option or Array:
 */
Option<Int>.none().map(toString)^ // Returns Option<String>.none()
ArrayK<Int>([]).map(toString)^    // Returns ArrayK<String>([])
/*:
 Despite not having values, the function `map` still changes the return type.
 
 `map` also works on types that have more than one type parameter, but only transforms the last one. For instance, we could apply it to `Either`:
 */
Either<Bool, Int>.right(2).map(toString)^    // Returns Either<Bool, String>.right("2")
Either<Bool, Int>.left(false).map(toString)^ // Returns Either<Bool, String>.left(false)
/*:
 ## Using a constant value
 
 #### Problem
 
 **I have**:
 
 - A value of type `F<A>`.
 - A value of type `B`.
 
 **I want**:
 
 - A value of type `F<B>`.
 
 #### Solution
 
 You can still use `map` and pass a function that returns the value of `B`, ignoring the input; however, the [Functor type class](https://bow-swift.io/next/api-docs/Protocols/Functor.html) provides the function `as`, that behaves like `map` but takes constant values instead of a transforming function.
 
 ## Clearing the type in the transformation
 
 #### Problem
 
 **I have**:
 
 - A value of type `F<A>`.
 
 **I want to have**:
 
 - A value of type `F<Void>`.
 
 #### Solution
 
 Likewise, you could use `map` with a function that returns `Void`, or `as` with the constant value of `()`, but the `Functor` type class provides the `void` function that does this for you.
 */
