---
layout: docs
title: Tail recursion
permalink: /docs/patterns/tail-recursion/
---

# Tail recursion
 
 {:.beginner}
 beginner
 
 Functional Programming relies a lot on recursion when it comes to iteration over values - also because some mathematical functions are naturally defined recursively. However, running recursive functions on a computer has a limit on the stack space we can use. If we get too deep on the recursive calls, it will cause a stack overflow and our code will crash. In this section, we will cover which techniques can help us overcome this problem.
 
## Regular recursion
 
 Consider a function to obtain a countdown from a given number down to 1 as a `String`. This can be implemented as a recursive function like:

```swift
func countdown_v1(_ n: Int) -> String {
    (n <= 0)
        ? ""
        : "\(n) " + countdown_v1(n - 1)
}
```

 This function will work fine for small inputs. We can run it with an input of 10:

```swift
countdown_v1(10) // Returns "10 9 8 7 6 5 4 3 2 1"
```

 However, running it with a larger number, like `100_000` will crash it. How can we address this?
 
## Tail recursive functions
 
 In order to fix this, we can make use of [tail recursive functions](https://en.wikipedia.org/wiki/Tail_call). A tail recursive function is a function that performs the recursive call as the last thing it does in its execution.
 
 If we analyze the previous function, it is not a tail recursive function, as the function needs to do more work after it returns from the recursion: it needs to concatenate the current number with the result of the recursion. This additional work that needs to be done prevents the current frame from being removed from the stack, consuming more and more stack space until it overflows. If we convert the function into a tail recursive function, the current frame could be removed from the stack, as no more work needs to be done with it, and therefore, the problem can be avoided.
 
 Fortunately, we can convert any recursive function in a tail recursive function by adding an additional parameter where the partial result is being tracked, and return this result in the base case of the recursion. That is:

```swift
func countdown_v2(_ n: Int) -> String {
    func countdown_tailRecursive(_ n: Int, _ result: String) -> String {
        (n == 0)
            ? result
            : countdown_tailRecursive(n - 1, "\(result) \(n)")
    }
    
    return countdown_tailRecursive(n, "")
}

countdown_v2(10) // Returns "10 9 8 7 6 5 4 3 2 1"
```

 This function is now tail recursive: it either returns the final result, or the last thing it does is performing the recursion.
 
 Nevertheless, if you run it with a larger number, you may still experience the same problem! The stack overflow problem persists. This happens because the Swift compiler does not perform tail call optimization. This optimization lets the compiler convert tail recursive functions into loops, using constant stack space and avoiding the stack overflow.
 
 If the compiler does not do this optimization, what can we do?
 
## Trampolining
 
 Bow provides a type called `Trampoline` that does tail call optimization. Once you have converted your function into a tail recursive function, you can perform additional changes to make it a trampolining function by wrapping the base case into `.done` and the recursive step into `.defer`.
 
 Thus, our final version of the countdown function could look like:

```swift
func countdown_v3(_ n: Int) -> String {
    func countdown_trampoline(_ n: Int, _ result: String) -> Trampoline<String> {
        (n <= 0)
            ? .done(result)
            : .defer { countdown_trampoline(n - 1, "\(result) \(n)") }
    }
    
    return countdown_trampoline(n, "").run()
}
```

 Notice that we can use an internal function to hide the implementation details of using `Trampoline`. Moreover, we need to call `run` on the final `Trampoline` to actually run the computation.
 
 With this implementation, we can call the function with large numbers and have stack safety.

```swift
countdown_v3(100_000) // Returns "100000 99999 99998 ... 3 2 1"
```
