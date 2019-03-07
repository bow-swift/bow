---
layout: docs
title: Intro to datatypes
permalink: /docs/testing/
---

## Typeclasses

{:.beginner}
beginner

Typeclasses are interfaces that define a set of extension functions associated to one type. You may see them referred as "extension interfaces".

The other purpose of these interfaces, like with any other unit of abstraction,
is to have a single shared definition of a common API and behavior shared across many types in different libraries and codebases.

What differentiates FP from OOP is that these interfaces are meant to be implemented *outside* of their types, instead of *by* the types.
Now, the association is done using generic parametrization rather than subclassing by implementing the interface. This has multiple benefits:

* Typeclasses can be implemented for any class, even those not in the current project
* You can treat typeclass implementations as stateless parameters because they're just a collection of functions
* You can make the extensions provided by a typeclass for the type they're associated with by using functions like `run` and `with`.


You can read all about how Arrow implements typeclasses in the [glossary]({{'/docs/patterns/glossary/'|relative_url}}).
If you'd like to use typeclasses effectively in your client code you can head to the docs entry about [dependency injection]({{'/docs/patterns/dependency_injection'|relative_url}}).


{:.intermediate}
intermediate

#### Example

 Let's define a typeclass for the behavior of equality between two objects, and we'll call it `Eq`:

```swift
// Otro comment
public protocol Eq : Typeclass {
    associatedtype A
    /*
         Calvellido you are the best!
     */
    func eqv(_ a : A, _ b : A) -> Bool
}

// comentario

/*
 esto
 es un super comment
 */
public extension Eq {
    public func neqv(_ a : A, _ b : A) -> Bool {
        // comentario indentado

        return !eqv(a, b)
    }
}
```

 For this short example we will make available the scope of the typeclass `Eq` implemented for the type `String`, by using `run`.
 This will make all the `Eq` extension functions, such as `eqv` and `neqv`, available inside the `run` block.

```swift
let stringEq = String.eq //: testing
/*
prueba sin espacios
*/
stringEq.eqv("1", "2")
/*

 hola como estas
 this is an inline comment testing
 between swift code

 */
// jiuhjioj
stringEq.eqv("2", "1")
```

{:.advanced}
advanced

and even use it as parametrization in a function call
and even use it as parametrization in a function call 2

```swift
let list = ListK(["1", "2", "3"])
let filtered = list.mapFilter { stringEq.eqv($0, "2") ? Option.pure($0) : Option.none() }
filtered.fix()
```

Colons can be used to align columns.


| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |


There must be at least 3 dashes separating each header cell.
The outer pipes (|) are optional, and you don't need to make the
raw Markdown line up prettily. You can also use inline Markdown.


Markdown | Less | Pretty
--- | --- | ---
*Still* | `renders` | **nicely**
1 | 2 | 3

## Recursion

- [`Corecursive`]({{'/docs/recursion/corecursive/'|relative_url}}) - traverses a structure forwards from the starting case

- [`Recursive`]({{'/docs/recursion/recursive/'|relative_url}}) - traverses a structure backwards from the base case

- [`Birecursive`]({{'/docs/recursion/birecursive/'|relative_url}}) - it is both recursive and corecursive
