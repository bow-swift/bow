---
layout: docs
title: Dependency management Overview
permalink: /docs/dependency-management/dependency-management-overview/
---

# Dependency management Overview
 
 In order to handle complexity in our code, we tend to divide it into different modules or layers, which we assemble and compose to solve the problem we are addressing. Oftentimes, we refer to these as dependencies that need to be provided to a certain module, so that it can perform its tasks.
 
 Dependencies can be modeled as a protocol which accepts different implementations. We can supply, for instance, one instance for production and another one that we can control for testing.
 
 In this section of the documentation, different techniques for dependency management are presented:
 
 - *Partial application*: make dependencies explicit as function arguments, and create versions of those functions where specific values are passed for each dependency.
 - *Constructor-based*: provide all dependencies in the initialization of a class/struct and use them in its methods.
 - *Reader*: defer supplying the dependencies by encapsulating them in a Kleisli function, that is returned as part of the execution of an operation with dependencies.
 
 These techniques are isomorphic to each other; that is, you can use them interchangeably. However, each one of them provides different ergonomics:
 
 | Technique | Benefits | Drawbacks |
 | --------- | -------- | --------- |
 | Partial application | Simple to use, just passing parameters. | Difficult to scale. Difficult to pass transitive dependencies. |
 | Constructor-based | Hides internal dependencies inside a module. | Dependencies become implicit and hinder local reasoning. |
 | Reader | Highly composable. | Difficult to work with many dependencies if they are not handled carefully. |
