// nef:begin:header
/*
 layout: docs
 title: Combining independent computations
 */
// nef:end
// nef:begin:hidden
import Bow
// nef:end
/*:
 # Combining independent computations
 
 {:.beginner}
 beginner
 
 ## Combining effectful values into a tuple
 
 #### Problem
 
 **I have**:
 
 - Several values of types `F<A1> ... F<An>`.
 
 **I want to have**:
 
 - A single value of type `F<(A1, ..., An)>`.
 
 #### Solution
 
 You can `zip` values of different types inside an effect. `zip` is an operation in the [Applicative type class](https://bow-swift.io/next/api-docs/Protocols/Applicative.html) that will access the internals of each effectful value and provide a single effectful value with a tuple with all of them, if possible.
 
 #### Example
 
 Consider the following effectful values:
 */
let x: ArrayK<Int> = ArrayK([1, 2, 3])
let y: ArrayK<String> = ArrayK(["A", "B"])
let z: ArrayK<Bool> = ArrayK([true, false])
/*:
 We want to obtain all the tuples with all possible combinations of the three arrays. We can do it with:
 */
let result: ArrayK<(Int, String, Bool)> = ArrayK.zip(x, y, z)^
/*:
 ## Combining effectful values with a function
 
 #### Problem
 
 **I have**:
 
 - Several values of types `F<A1> ... F<An>`.
 - A function `(A1, ..., An) -> B`.
 
 **I want to have**:
 
 - A single value of type `F<B>`.
 
 #### Solution
 
 This case is similar to the above, but transforming the tuple into a single value using a function. The [Applicative type class](https://bow-swift.io/next/api-docs/Protocols/Applicative.html) provides the `map` function to achieve this purpose. It accepts several effectful values and a function. It will access the internals of each effectful value and feed all inputs, if possible, into the provided function.
 
 #### Example
 
 Consider the following data structure and functions:
 */
// nef:begin:hidden
struct View {}
let view = View()
// nef:end
struct User {
    let name: String
    let email: String
}

// Gets the name entered by the user in the UI, if any.
func readName(from view: View) -> Option<String>
// nef:begin:hidden
{ .none() }
// nef:end

// Gets the email entered by the user in the UI, if any.
func readEmail(from view: View) -> Option<String>
// nef:begin:hidden
{ .none() }
// nef:end
/*:
 If we want to create a `User` object from the information the user has entered in the UI, we need both name and email to be present. Using `map`, we can achieve this:
 */
let user = Option.map(readName(from: view),
                      readEmail(from: view),
                      User.init)^
/*:
 If both functions `readName` and `readEmail` return a present `Option`, the User initializer will be called and a User will be created. If any of them returns `none`, the end result will be `none`.
 */
