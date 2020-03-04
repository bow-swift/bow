---
layout: docs
title: Glossary
permalink: /docs/fp-concepts/glossary/
---

# Glossary

 {:.beginner}
 beginner
 
 This is a compendium of some of the terminology that is used in the documentation for Bow and in literature about Functional Programming. It is expected to grow over time as we make progress in the documentation of the library. If there is a term that you would like to see in this list, please, open an issue and we will consider adding it here.

# A

### Ad-hoc polymorphism

 **Ad-hoc polymorphism** is a type of polymorphism achieved by having functions with the same name but different signatures and/or different number of arguments. In Functional Programming, ad-hoc polymorphism is achieved with type classes that act as constraints added to type parameters in parametrically polymorphic types or functions. Ad-hoc polymorphism is also known as function overloading.

# F

### Function

 A function is a piece of code that has the following properties:

 - **Total**: it must provide an output for every input.
 - **Deterministic**: for a given input, the function always returns the same output.
 - **Pure**: the evaluation of the function does not cause any other effects besides computing the output.

 Notice that Swift does not enforce any of these properties in their definition. Swift functions that have these properties are generally referred as **pure functions**, whereas the ones that do not have some of them are called **impure functions**.

### Functional Programming

 **Functional Programming** is a programming paradigm that treats computation as the evaluation of mathematical functions and avoids changing state and mutable data.

# I

### Instance (of a type class)

 An **instance** of a type class is the implementation of such type class for a given type. They are usually done in Swift using the `extension` functionality in the language.

# K

### Kind

 A **kind** is a group of types. As values are grouped into types, types are grouped into kinds. The notion of kind lets us conceptualize type constructors that receive a number of type arguments and abstract over them. This generalization is known as **higher kinded types** and enable generic polymorphic programs. Swift does not support this feature natively, but it is simulated in Bow.

# M

### Memoization

 **Memoization** is an optimization technique that transforms expensive computational function calls into searches in a lookup table by caching previous calls.

# P

### Parametric polymorphism

 **Parametric polymorphism** is a type of polymorphism that allows specifying generic types to create functions and/or other types. These generic types are called *type parameters*.

### Procedure

 A **procedure** is a Swift function that is not total, deterministic and/or pure, as required in the mathematical definition of function. Generally, it is referred to as an **impure function**.

# R

### Referential Transparency

 **Referential transparency** is a property of a function that allows it to be replaced by the result of its execution without altering the overall behavior of the program.

# T

### Type

 A **type** is a set of values that helps us conceptualize data and restrict the possible values that functions can accept as input or provide as output. Types can be finite (like `Bool`, with two values: `true` and `false`) or infinite (like `String`).

### Type class

 A **type class** is a group of functions that operate on generic type parameters and is governed by algebraic laws. They are usually represented in Swift as protocols with associated types or self requirements.

### Type constructor

 A **type constructor** is a type that receives other types and produces new types. Examples of type constructors are `Array<Element>` or `Optional<Wrapped>`, where providing types for `Element` or `Wrapper` types yields new types like `Array<Int>` or `Optional<String>`.

### Type parameter

 A **type parameter** is a placeholder in a type constructor or generic function that let us provide different types and generate a family of types or functions. For instance, in `Array<Element>`, `Element` is a type parameter for `Array` and replacing with concrete types yields a family of new types.

# W

### Witness

 A **witness** is an intermediate class that is used to simulate Higher Kinded Types in Bow. As a convention, they are prefixed by `For`. As an example, consider the `Option<A>` data type in Bow. This data type extends `Kind<ForOption, A>` in order to enable HKT support. `ForOption` is the witness for `Option`.
