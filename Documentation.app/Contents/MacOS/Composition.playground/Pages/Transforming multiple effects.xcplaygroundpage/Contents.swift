// nef:begin:header
/*
 layout: docs
 title: Transforming multiple effects
 */
// nef:end
// nef:begin:hidden
import Bow
// nef:end
/*:
 # Transforming multiple effects
 
 {:.beginner}
 beginner
 
 ## Transforming with an effecful function
 
 #### Problem
 
 **I have**:
 
 - A value of type `F<A>`.
 - A function of type `(A) -> G<B>`.
 
 **I want to have**:
 
 - A value of type `F<G<B>>`.
 
 #### Solution
 
 Despite having two different effects, they do not interact with each other. This is a regular `map` transformation, as provided in the [Functor type class](https://bow-swift.io/next/api-docs/Protocols/Functor.html).
 
 #### Example
 
 Consider having an array of values of type String, and trying to parse each value to an Int. Parsing is an effectul operation as it can return a value, if the number can be parsed, or `none`, otherwise. In this case, our `F` is `Array` and our `G` is Option:
 */
func parseInt(_ str: String) -> Option<Int> {
    Int(str).toOption()
}
//             F<A>
let array: Array<String> = ["1", "5", "3"]

//                    F  <  G   < B >>
let arrayOfOptions: Array<Option<Int>> = array.map(parseInt)

/*:
 ## Swapping effects
 
 #### Problem
 
 **I have**:
 
 - A value of type `F<G<A>>`.
 
 **I want to have**:
 
 - A value of type `G<F<A>>`.
 
 #### Solution
 
 If we want to swap the relative order of the applied effects, we can use the `sequence` function, provided in the [Traverse type class](https://bow-swift.io/next/api-docs/Protocols/Traverse.html).
 
 #### Example
 
 If we take the previous example, where we have an `Array<Option<Int>>` and we want to have an `Option<Array<Int>>`, which will be present if all elements in the array are present, or `none` if any of the elements is `none, we need to apply the `sequence` function:
 */
// Returns Option.some([1, 5, 3])
let optionArray: Option<Array<Int>> = arrayOfOptions.sequence()^
/*:
 If any of the elements of the array is `none`, the result of `sequence` is `none`:
 */
let arrayWithNone: Array<Option<Int>> = [.some(1), .none()]
let noneArray: Option<Array<Int>> = arrayWithNone.sequence()^
/*:
 ## Transforming and swapping with an effectful function
 
 #### Problem
 
 **I have**:
 
 - A value of type `F<A>`.
 - A function `(A) -> G<B>`.
 
 **I want to have**:
 
 - A value of type `G<F<B>>`.
 
 #### Solution
 
 Looking at the type signatures we have above, this pattern is equivalent to doing `map` and then `sequence`. There is a function that does this in a single step: `traverse`, provided by the [Traverse type class](https://bow-swift.io/next/api-docs/Protocols/Traverse.html).
 
 #### Example
 
 We can run the previous examples in a single step:
 */
let numbers = ["1", "5", "3"]
// Returns Option.some([1, 5, 3])
let parsedNumbers: Option<[Int]> = numbers.traverse(parseInt)^

let nonNumbers = ["9", "abc", "3"]
// Returns Option.none()
let notParsedNumbers: Option<[Int]> = nonNumbers.traverse(parseInt)^
