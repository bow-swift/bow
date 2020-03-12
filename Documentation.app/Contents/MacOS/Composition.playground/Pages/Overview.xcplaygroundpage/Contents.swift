// nef:begin:header
/*
 layout: docs
 title: Composition: The essence of Functional Programming
 */
// nef:end
/*:
 # Composition: The essence of Functional Programming

 The unit of work in Functional Programming is a function. It is the smallest building block that we can create to solve a programming problem. Functions, as they are understood in FP, must have the following characteristics:
 
 - **Total**: they must be defined for every possible input.
 - **Deterministic**: they must return the same output for a given input.
 - **Pure**: the only observable effect of running them is their output.
 
 When we have these building blocks, we need to combine them somehow to solve bigger problems. This is done by **composition**. Composition is the cornerstone of FP - it lets us build entire functional applications from total, deterministic, pure functions.
 
 Nevertheless, composition can be tricky, especially when we start dealing with effectful and side effectful operations. In this section of the documentation, we will review different patterns for composition that you will encounter regularly.
 
 ## Summary
 
 The following table summarizes typical use cases and lets you find which operation you will need to use to compose operations, and which type class provides it.
 
 | I have... | I want to... | Function | Type class |
 | --------- | ------------ | -------- | ---------- |
 | One or more elements of `A` | Combine them into a single `A` | `combine` / `combineAll` | Semigroup |
 | Zero or more elements of `A` | Combine them into a single `A` | `combine` / `combineAll` + `empty` | Monoid |
 | A value `F<A>` and a function `(A) -> B` | Obtain a value `F<B>` | `map` | Functor |
 | Several values `F<A1> ... F<An>` | Combine them into `F<(A1, ..., An)>` | `zip` | Applicative |
 | Several values `F<A1> ... F<An>` and a function `(A1 ... An) -> B` | Combine them into `F<B>` | `map` | Applicative |
 | A value `F<A>` and a function `(A) -> F<B>` | Obtain a value `F<B>` | `flatMap` | Monad |
 | A value `F<A>` and a function `(A) -> G<B>` | Obtain a value `F<G<B>>` | `map` | Functor |
 | A value `F<A>` and  a function `(A) -> G<B>` | Obtain a value `G<F<B>>` | `traverse` | Traverse |
 | A value `F<G<A>>` | Flip the effects to get `G<F<A>>` | sequence | Traverse |
 */
