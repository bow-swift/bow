// nef:begin:header
/*
 layout: docs
 title: Glossary
 */
// nef:end
/*:
 # Glossary

 {:.beginner}
 beginner
 
 This is a compendium of some of the terminology that is used in the documentation for Bow and in literature about Functional Programming. It is expected to grow over time as we make progress in the documentation of the library. If there is a term that you would like to see in this list, please, open an issue and we will consider adding it here.

 # A

 ### Ad-hoc polymorphism

 **Ad-hoc polymorphism** is a type of polymorphism achieved by having functions with the same name but different signatures and/or different number of arguments. In Functional Programming, ad-hoc polymorphism is achieved with type classes that act as constraints added to type parameters in parametrically polymorphic types or functions. Ad-hoc polymorphism is also known as function overloading.

 ### Algebra
 
 An **algebra** is a set of operations that work with elements of a given type. This operations are governed by a set of properties, called **algebraic laws**. In Swift, a common way of representing an algebra is by using a `protocol` that operates on `Self` or has associated types.
 
 ### Algebraic Data Types
 
 An **algebraic data type** (ADT) is a type that is made of **product types** and **sum types**. ADTs are useful to model data structures and make illegal states impossible to represent.
 
 ### Arity
 
 **Arity** refers to the number of arguments something can receive. The arity of a function is the number of inputs it can receive. The arity of a type constructor is the number of type arguments it can receive. Depending on its arity, we can refer to elements as unary (arity of 1), binary (arity of 2), ternary (arity of 3)...
 
 ### Associativity
 
 **Associativity** is the property of a binary operation by which, when given three elements `a, b, c`, operating first on the first two elements an then on the last, provides the same result that operating first on the last two elements, and then on the first; i.e. `op(op(a, b), c) == op(a, op(b, c))`.
 
 # C
 
 ### Closure
 
 A **closure** is an inline function, created in Swift by wrapping the body of the closure inside `{}`, that can be passed to, or returned from, a higher-order function.
 
 ### Composition
 
 **Composition** is the essence of Functional Programming; it is the operation by which we can create larger programs from small building blocks.
 
 ### Currying
 
 **Currying** is an operation to transform a function that receives multiple arguments (2 or more) into a function that only has one argument and returns another function with the same characteristics. That is, given a function `(A, B) -> C`, its *curried* version is `(A) -> (B) -> C`.
 
 Currying has a dual operation called **uncurrying**, which operates exactly the oposite way: given a function `(A) -> (B) -> C`, it returns a function `(A, B) -> C`.
 
 # D
 
 ### Determinism
 
 **Determinism** is the property of a piece of code by which its output is uniquely obtained from its input, and nothing else.
 
 # E
 
 ### Effect
 
 An **effect**, or **functional effect**, is an immutable data type that describes the computation of one or more values, with additional features (like error handling, asynchrony, state, etc.). It usually has the form `F<A>`, where `F` is the effect type, and `A` is the type of the resulting computation.
 
 Some examples of functional effects are:
 
 - `Option&lt;A&gt;`, to model potentially absent values.
 - `Either<B, A>`, to model computations that may fail.
 - `State<S, A>`, to model state-based computations.
 - `ArrayK&lt;A&gt;`, to model computations that produce multiple values.
 - `Kleisli<F, D, A>`, to model `F`-effecful computations that depend on an environment of type `D`.
 - `IO<E, A>`, to model side-effectful computations.
 
 # F

 ### F-algebra
 
 An **F-algebra** is a function `(F<A>) -> A`, that is commonly used in **Recursion Schemes**.
 
 ### Function

 A function is a piece of code that has the following properties:

 - **Total**: it must provide an output for every input.
 - **Deterministic**: for a given input, the function always returns the same output.
 - **Pure**: the evaluation of the function does not cause any other effects besides computing the output.

 Notice that Swift does not enforce any of these properties in their definition. Swift functions that have these properties are generally referred as **pure functions**, whereas the ones that do not have some of them are called **impure functions**.

 ### Functional Programming

 **Functional Programming** is a programming paradigm that treats computation as the evaluation of mathematical functions and avoids changing state and mutable data.

 # H
 
 ### Higher-order function
 
 A **higher-order function** is a function that receives one or more functions as input, and/or returns a function as a result of its execution.
 
 # I

 ### Identity
 
 The **identity** function is a function that returns its input, unmodified.
 
 ### Instance (of a type class)

 An **instance** of a type class is the implementation of such type class for a given type. They are usually done in Swift using the `extension` functionality in the language.

 ### Isomorphism
 
 An **isomorphism** is a pair of functions that, when composed, they return the identity function. That is, given `f` and `g`, they form an isomorphism if `f <<< g == g <<< f == id`.
 
 Two data types `A` and `B` are **isomorphic** if we can find a pair of functions `f: (A) -> B` and `g: (B) -> A` that form an isomorphism. That means `A` and `B` are not exactly *equal*, but they are *equivalent*.
 
 # K

 ### Kind

 A **kind** is a group of types. As values are grouped into types, types are grouped into kinds. The notion of kind lets us conceptualize type constructors that receive a number of type arguments and abstract over them. This generalization is known as **higher kinded types** and enable generic polymorphic programs. Swift does not support this feature natively, but it is simulated in Bow.

 # L
 
 ### Lambda
 
 See **Closure**.
 
 # M

 ### Memoization

 **Memoization** is an optimization technique that transforms expensive computational function calls into searches in a lookup table by caching previous calls.

 # O
 
 ### Optics
 
 **Optics** are values that let us operate on deeply nested immutable data structures, easing the obtention and modification of its data and hiding the boilerplate associated with its destructuring, copy and restructuring.
 
 # P

 ### Parametric polymorphism

 **Parametric polymorphism** is a type of polymorphism that allows specifying generic types to create functions and/or other types. These generic types are called *type parameters*.

 ### Procedure

 A **procedure** is a Swift function that is not total, deterministic and/or pure, as required in the mathematical definition of function. Generally, it is referred to as an **impure function**.

 ### Product type
 
 A **product type** is the composition of `n` types, where one value of each individual type is needed in order to create a value of the product. In Swift, product types can be created using classes, structs or tuples.
 
 ### Purity
 
 **Purity** is the property of a function by which it does not cause side effects when it is invoked.
 
 # R

 ### Recursive function
 
 A **recursive function** is a function that calls itself in the definition of its body. A **tail-recursive function** is a recursive function that performs its recursive step as the last operation it does in the execution of its body.
 
 ### Referential Transparency

 **Referential transparency** is a property of a function that allows it to be replaced by the result of its execution without altering the overall behavior of the program.

 # S
 
 ### Side effect
 
 A **side effect** is an observable event in the outside world that happens after the invocation of a function, and its other than computing its result value. Common side effects are logging, network access, file system access, etc.
 
 ### Sum type
 
 A **sum type** is the composition of `n` types where a value of the sum type can only take a single value of one of the individual types. In Swift, sum types are typically modeled with enums.
 
 # T

 ### Totality
 
 **Totality** is the property of a function by which it is defined for every possible input.
 
 ### Trampolining
 
 **Trampolining** is a technique to make recursive functions consume constant stack space in order to prevent stack overflow problems.
 
 ### Type

 A **type** is a set of values that helps us conceptualize data and restrict the possible values that functions can accept as input or provide as output. Types can be finite (like `Bool`, with two values: `true` and `false`) or infinite (like `String`).

 ### Type class

 A **type class** is a group of functions that operate on generic type parameters and is governed by algebraic laws. They are usually represented in Swift as protocols with associated types or self requirements.

 ### Type constructor

 A **type constructor** is a type that receives other types and produces new types. Examples of type constructors are `Array<Element>` or `Optional<Wrapped>`, where providing types for `Element` or `Wrapper` types yields new types like `Array<Int>` or `Optional<String>`.

 ### Type parameter

 A **type parameter** is a placeholder in a type constructor or generic function that let us provide different types and generate a family of types or functions. For instance, in `Array<Element>`, `Element` is a type parameter for `Array` and replacing with concrete types yields a family of new types.

 # U
 
 ### Uncurrying
 
 See **Currying**.
 
 # W

 ### Witness

 A **witness** is an intermediate class that is used to simulate Higher Kinded Types in Bow. As a convention, they are prefixed by `For`. As an example, consider the `Option<A>` data type in Bow. This data type extends `Kind<ForOption, A>` in order to enable HKT support. `ForOption` is the witness for `Option`.
 */
