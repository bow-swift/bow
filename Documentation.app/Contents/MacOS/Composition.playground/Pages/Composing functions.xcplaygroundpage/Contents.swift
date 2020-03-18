// nef:begin:header
/*
 layout: docs
 title: Composing functions
 */
// nef:end
// nef:begin:hidden
import Bow
// nef:end
/*:
 # Composing functions
 
 {:.beginner}
 beginner

 ## Composing regular functions
 
 #### Problem
 
 **I have**:
 
 - A function `f: (A) -> B`
 - A function `g: (B) -> C`
 
 **I want to have**:
 
 - A function `h: (A) -> C`
 
 #### Solution
 
 Bow provides the `compose` function and the `<<<` operator to compose two functions. `g <<< f` is typically read as `g` after `f`, and refers to first applying `f` to a value of type `A`, and then applying `g` to the result.
 
 Although this works nicely, it is sometimes cumbersome to use, as it needs to be read right-to-left. In order to improve that, Bow provides the `andThen` function and the `>>>` operator, which do exactly the same, but their arguments are flipped. Therefore, `g <<< f` is equivalent to `f >>> g`; likewise, `compose(g, f)` is equivalent to `andThen(f, g)`.
 
 #### Example
 
 Consider the following functions:
 */
// Computes the length of a circumference from its radius.
func circumference(radius: Int) -> Double {
    2 * .pi * Double(radius)
}

// Obtains a String from a Double, keeping only 2 decimal places.
func prettyPrint(_ n: Double) -> String {
    String(format: "%.2f", n)
}

/*:
 We can create a function that, given a radius, it gives us the length of a circumference with only two decimal places. This can be achieved by composing the previous two functions:
 */
let prettyCircumference: (Int) -> String =
    circumference(radius:) >>> prettyPrint

prettyCircumference(3) // Returns "18.85"
/*:
 ## Composing effectful functions
 
 #### Problem
 
 **I have**:
 
 - A function `f: (A) -> F<B>`.
 - A function `g: (B) -> F<C>`.
 
 **I want to have**:
 
 - A function `h: (A) -> F<C>`.
 
 #### Solution
 
 The previous composition functions and operators do not work here. If we inspect the return type of `f`, it does not match with the input type of `g`, since the functions are effectful.
 
 These effectful functions are called [**Kleisli** functions](https://bow-swift.io/next/api-docs/Classes/Kleisli.html), and there is a type in Bow to represent them. The `Kleisli` type provides the `andThen` method to compose them.
 
 #### Example
 
 Consider the following functions:
 */
// nef:begin:hidden
struct Conference {}
struct Talk {}
// nef:end
// Provides the next conference after a certain date, if it exists.
func nextConference(after date: Date) -> Option<Conference>
// nef:begin:hidden
{ .none() }
// nef:end

// Provides the next talk for a Conference, if it exists.
func nextTalk(at conference: Conference) -> Option<Talk>
// nef:begin:hidden
{ .none() }
// nef:end
/*:
 Both functions are Kleisli functions, as their result are effectful, with Option being the effect. We can compose them into a function that provides the next Talk after a certain date, if it exists:
 */
// Kleisli<ForOption, Date, Talk> is equivalent to a function:
// (Date) -> Option<Talk>
let nextTalkAfterDate: Kleisli<ForOption, Date, Talk> = Kleisli(nextConference(after:))
    .andThen(Kleisli(nextTalk(at:)))
/*:
 And we can invoke this function as:
 */
nextTalkAfterDate.run(Date())
