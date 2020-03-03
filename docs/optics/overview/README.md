---
layout: docs
title: Overview
permalink: /docs/optics/overview/
---

# Overview
 
 {:.beginner}
 beginner
 
 The optics module in Bow provides several utilities to work with immutable data structures. It enables easy access to getting, setting and modifying deeply nested data structure without the burden of making explicit copies of the involved values.
 
 In order to use the module, you just need to import it:

```swift
import BowOptics
```

 This module includes multiple facilities to work with immutable nested data structures:
 
 - Optics: it includes several data types that let us work with different types of structures.
 - Type classes: several abstractions are provided to generalize operations of accessing data structures internals.
 - Automatic generation: in some cases, the library is able to automatically provide certain optics for some data types, so that you do not need to write them.
 
## Optics
 
 The provided optics operate on two type arguments that are typically named `S` and `A`, which correspond to the source (the whole structure we have) and the focus (the part we want to obtain or modify). The following table summarizes the individual optics that are provided in `BowOptics`:
 
 | Optic     | Description |
 | --------- | ----------- |
 | Iso       | A lossless invertible optic defining an isomorphism between two types |
 | Getter    | An optic that can focus into a structure and get its focus |
 | Setter    | An optic that can focus into a structure and set or modify its focus |
 | Lens      | An optic that can focus into a structure and get, set or modify its focus |
 | Optional  | An optic whose focus is optional and can get, set or modify it |
 | Prism     | An optic whose focus is present only in some cases (of a sum type) and can get, set or modify it |
 | Fold      | An optic that can have multiple foci and is able to fold them into a single value |
 | Traversal | An optic that can have multiple foci and get, set or modify them |

 Besides, the optics provided in this module are able to operate polymorphically. In this case, their name is prepended by a `P` (e.g. `PIso`, `PLens` or `PPrism`) and have two additional type parameters: `T`, the modified source, and `B`, the modified focus. This means those optics can operate on structures that change the type of the source or the focus (usually parametrically polymorphic types).
 
## Type classes
 
 These are the provided type classes in the `BowOptics` module:
 
 | Type class  | Description |
 | ----------- | ----------- |
 | Cons        | Splits a structure into its first element and the rest |
 | Snoc        | Splits a structure into a prefix with all elements but the last, and the last |
 | At          | Provides a Lens at a given index |
 | Index       | Provides an Optional at a given index |
 | FilterIndex | Provides a Traversal of elements whose index fulfils a predicate |
 | Each        | Provides a Traversal that can focus into a structure to see all foci |
