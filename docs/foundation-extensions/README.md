---
layout: docs
title: Foundation extensions
permalink: /docs/effects/foundation-extensions/
---

# Foundation extensions
 
 {:.beginner}
 beginner
 
 Foundation for Swift provides an important amount of resources for Swift developers as a standard library. However, most of this functionality is not pure from the FP point of view, as some of the methods that we can call produce side effects. Besides, in some cases the APIs are not well designed in terms of algebraic data types.
 
 BowEffects provides a wrapper over some APIs in Foundation so that you can make use of them in a functional manner.
 
## Console
 
 Functions `print` and `readLine` are global functions that write to and read form the standard input/output, producing side effects. Bow Effects wraps them under `ConsoleIO`, which provides methods with the exact same signature but returning an `IO` value that describes the operation.
 
## URLSession
 
 Networking operations can be done through `URLSession`. It provides `dataTask`, `downloadTask` and `uploadTask` functions with different overloads to perform different operations.
 
 Bow Effects provides an extension over `URLSession` with the same methods with the suffix `IO`, e.g. `dataTaskIO`, `downloadTaskIO` and `uploadTaskIO`. They offer the same overloads as their original counterparts but wrapping their results in an `IO` value that suspends the effects and encapsulates the results and errors that are produced by those operations.
 
## FileManager
 
 `FileManager` provides multiple operations to work with the file system and its directories, both locally and in the cloud. As in the case of `URLSession`, Bow Effects provide extensions to `FileManager` by appending `IO` to those operations that are side-effectful. Note that not all the methods in `FileManager` are wrapped; the ones that do not have an `IO` counterpart are safe to be used as they do not produce side-effects.
