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

 # F

 ### Function

 A function is a piece of code that has the following properties:

 - **Total**: it must provide an output for every input.
 - **Deterministic**: for a given input, the function always returns the same output.
 - **Pure**: the evaluation of the function does not cause any other effects besides computing the output.

 Notice that Swift does not enforce any of these properties in their definition. Swift functions that have these properties are generally referred as **pure functions**, whereas the ones that do not have some of them are called **impure functions**.

 ### Functional Programming

 **Functional Programming** is a programming paradigm that treats computation as the evaluation of mathematical functions and avoids changing state and mutable data.

 # M

 ### Memoization

 **Memoization** is an optimization technique that transforms expensive computational function calls into searches in a lookup table by caching previous calls.

 # P

 ### Procedure

 A **procedure** is a Swift function that is not total, deterministic and/or pure, as required in the mathematical definition of function. Generally, it is referred to as an **impure function**.

 # R

 ### Referential Transparency

 **Referential transparency** is a property of a function that allows it to be replaced by the result of its execution without altering the overall behavior of the program.
 */
