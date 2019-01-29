import Foundation

/// Memoizes a 1-ary function.
///
/// Memoization is a useful technique to cache already computed values, specially in functions with a high computational cost. It requires the input parameter to the function to be `Hashable` in order to be able to save the computed result.
/// This function returns a memoized function that behaves the same as the original one. Given an input, first invokation of the memoized function will compute the result and store it. Subsequent invokations with the same input will not be computed; the stored result will be returned instead.
 
/// - Parameters:
///   - f: Function to be memoized. This function must be pure and deterministic in order to have consistent results.
///   - a: Function input.
/// - Returns: A function that behaves like `f` but saves already computed results.
public func memoize<A, B>(_ f : @escaping (_ a: A) -> B) -> (A) -> B where A : Hashable {
    var cached = Dictionary<A, B>()
    
    return { a in
        if let cachedResult = cached[a] {
            return cachedResult
        }
        let result = f(a)
        cached[a] = result
        return result
    }
}

/// Memoizes a recursive 1-ary function.
///
/// In order to memoize a recursive function, the recursive step must be memoized as well. In order to do so, callers of this function must pass a function that will receive the memoized function and the current input, and use both to provide the output. Input parameters must conform to `Hashable`.
/// As an example, consider this implementation of a memoized factorial:
///
///     let memoizedFactorial: (Int) -> Int = memoize { factorial, x in
///         x == 0 ? 1 : x * factorial(x - 1)
///     }
///
/// - Parameters:
///   - f: Function to be memoized.
///   - step: A closure describing a recursive step of the function.
///   - a: Input to the recursive step.
///   - input: Current value for the recursion.
/// - Returns: A function that behaves like `f` but saves already computed results.
public func memoize<A, B>(_ f : @escaping (_ step: (_ a: A) -> B, _ input: A) -> B) -> (A) -> B where A : Hashable {
    var cached = Dictionary<A, B>()
    
    func wrap(_ a : A) -> B {
        if let cachedResult = cached[a] {
            return cachedResult
        }
        let result = f(wrap, a)
        cached[a] = result
        return result
    }
    
    return wrap
}
