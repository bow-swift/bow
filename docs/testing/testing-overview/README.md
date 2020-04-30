---
layout: docs
title: Testing
permalink: /docs/testing/testing-overview/
---

# Testing
 
 {:.beginner}
 beginner
 
 Purely functional code is intrinsically testable. Functions written in this paradigm are total, deterministic, and pure; therefore, we can see them as black boxes where we supply inputs, and assert on the outputs, as these only depend on what we have supplied.
 
 This enables a range of different testing techniques to be used. We can rely on common **example-based testing**, where we select a few examples as inputs to our functions, and perform assertions with our expected outputs.
 
 We can also turn these example-based tests into **parametric tests**, by taking lists where we choose inputs to explore corner cases of our implementations, together with the expected result for each of them.
 
 Going even further, functional code is often tested using a technique known as **property-based testing**. In fact, most of the code in Bow is tested following this approach, using [SwiftCheck](https://github.com/typelift/SwiftCheck). With this technique, we provide generators for our input parameters, and verify properties of the output of one or more functions that we have implemented. This reduces the bias of our chosen examples, and increases the confidence we can have on our implementation, as it gets tested with many randomly chosen inputs every time we run our tests.
 
 These techniques are not exclusive, but complementary to each other. Property tests provide solid trust on our confidence while testing at a higher level; example or parametric tests serve as a way of testing specific paths that may be of high importance, and as documentation of concrete decisions.
