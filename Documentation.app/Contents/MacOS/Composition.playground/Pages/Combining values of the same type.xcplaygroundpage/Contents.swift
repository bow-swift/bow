// nef:begin:header
/*
 layout: docs
 title: Combining values of the same type
 */
// nef:end
// nef:begin:hidden
import Bow
// nef:end
/*:
 # Combining values of the same type
 
 {:.beginner}
 beginner
 
 ## Having one or more values
 
 #### Problem
 
 **I have**:
 
 - One or more values of type `A`.
 
 **I want to have**:
 
 - A single value of type `A`.
 
 #### Solution
 
 If you have several values of the same type (at least one), you can `combine` them into a single value. `combine` is a binary operation; i.e., you need two values of type `A` to combine them into one.
 
 If you have more than two elements, you can either chain multiple `combine` calls, or use `combineAll`, which accepts a variadic number of parameters.
 
 This operation is available in the [Semigroup type class](https://bow-swift.io/next/api-docs/Protocols/Semigroup.html), and it is an associative operation. Your type must conform to `Semigroup` in order to have `combine` available.
 
 #### Example
 
 Basic types like numeric types or Strings already conform to `Semigroup` in Bow. For instance, we can combine `Int` values like:
 */
let x = 2
let y = 5
let z = 8

x.combine(y) // Returns 7
Int.combineAll(x, y, z) // Returns 15
/*:
 The operation is associative; that is, we can first combine `x` and `y`, and then `z`, or first `y` and `z`, and then `x`.
 */
x.combine(y).combine(z) == x.combine(y.combine(z))
 /*:However, the operation is **not necessarily commutative**: combining `x` with `y` may not be the same as combining `y` and `x`. This becomes evident with Strings:
 */
let a = "Hello"
let b = "World"

a.combine(b) != b.combine(a)
/*:
 ## Having zero or more values
 
 #### Problem
 
 **I have**:
 
 - Zero or more values of type `A`.
 
 **I want to have**:
 
 - A single value of type `A`.
 
 #### Solution
 
 The problem described here is similar to the problem above, with the difference of potentially having no values. We can use `combine`, but we need to provide a *default* value when no values are combined.
 
 This default value is `empty` and it is available in the [Monoid type class](https://bow-swift.io/next/api-docs/Protocols/Monoid.html). `empty` has the property of being combinable with any other element of the type, yielding the same value it is combined with.
 
 #### Example
 
 Like with Semigroups, basic types in Swift already conform to `Monoid` in Bow.
 */
x.combine(Int.empty()) // Returns x
Int.empty().combine(x) // Returns x
/*:
 ## Combining your own types
 
 #### Problem
 
 I have my own type and I need to combine elements of this type.
 
 #### Solution
 
 You need to use Swift `extension` mechanisms to make your type conform to `Semigroup` and `Monoid`, guaranteeing that your implementation honors the properties of both type classes.
 
 #### Example
 
 Consider a type to model a shopping cart:
 */
struct ShoppingCart<Product> {
    let products: [Product]
    let amount: Double
}
/*:
 If I need to give it the ability to combine its values, I need to determine how each of its properties are combined with the ones in other values. In this case:
 
 - `products` can be combined by concatenating the arrays of the two carts that are being combined.
 - `amount` can be combined by adding the amounts of the two carts.
 
 Therefore, I can make an `extension` to conform to `Semigroup`:
 */
extension ShoppingCart: Semigroup {
    func combine(_ other: ShoppingCart<Product>) -> ShoppingCart<Product> {
        ShoppingCart(
            products: self.products + other.products,
            amount: self.amount + other.amount
        )
    }
}
/*:
 If I need to give it the ability to have an empty value, I need to determine how each of its properties need to be initialized to an empty value. In this case:
 
 - `products` can be initialized to an empty array.
 - `amount` can be initialized to `0.0`.
 
 Therefore, I can make an `extension to conform to `Monoid`:
 */
extension ShoppingCart: Monoid {
    static func empty() -> ShoppingCart<Product> {
        ShoppingCart(
            products: [],
            amount: 0.0
        )
    }
}
/*:
 ## Are all types that conform to Semigroup also conform to Monoid?
 
 If your type conforms to `Monoid` it also must conform to `Semigroup`, but the reverse is not true. You may be able to combine values of a type, but not be able to provide an empty value.
 
 One example of this is the `NonEmptyArray` type, which, as its name suggests, is never empty; therefore, it cannot provide an empty value for the combination.
 */
