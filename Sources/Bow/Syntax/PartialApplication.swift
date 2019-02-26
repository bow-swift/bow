import Foundation

infix operator |> : AdditionPrecedence

/// Applies an argument to a 1-ary function.
///
/// - Parameters:
///   - a: Argument to apply.
///   - fun: Function receiving the argument.
/// - Returns: Result of running the function with the argument as input.
public func |><A, B>(_ a : A, _ fun : (A) -> B) -> B {
    return fun(a)
}

/// Applies the first argument to a 2-ary function, returning a 1-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the first argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the first argument is fixed to the value of the provided argument.
public func |><A, B, C>(_ a : A, _ fun : @escaping (A, B) -> C) -> (B) -> C {
    return { b in fun(a,b) }
}

/// Applies the first argument to a 3-ary function, returning a 2-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the first argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the first argument is fixed to the value of the provided argument.
public func |><A, B, C, D>(_ a : A, _ fun : @escaping (A, B, C) -> D) -> (B, C) -> D {
    return { b, c in fun(a, b, c) }
}

/// Applies the first argument to a 4-ary function, returning a 3-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the first argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the first argument is fixed to the value of the provided argument.
public func |><A, B, C, D, E>(_ a : A, _ fun : @escaping (A, B, C, D) -> E) -> (B, C, D) -> E {
    return { b, c, d in fun(a, b, c, d) }
}

/// Applies the first argument to a 5-ary function, returning a 4-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the first argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the first argument is fixed to the value of the provided argument.
public func |><A, B, C, D, E, F>(_ a : A, _ fun : @escaping (A, B, C, D, E) -> F) -> (B, C, D, E) -> F {
    return { b, c, d, e in fun(a, b, c, d, e) }
}

/// Applies the first argument to a 6-ary function, returning a 5-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the first argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the first argument is fixed to the value of the provided argument.
public func |><A, B, C, D, E, F, G>(_ a : A, _ fun : @escaping (A, B, C, D, E, F) -> G) -> (B, C, D, E, F) -> G {
    return { b, c, d, e, f in fun(a, b, c, d, e, f) }
}

/// Applies the first argument to a 7-ary function, returning a 6-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the first argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the first argument is fixed to the value of the provided argument.
public func |><A, B, C, D, E, F, G, H>(_ a : A, _ fun : @escaping (A, B, C, D, E, F, G) -> H) -> (B, C, D, E, F, G) -> H {
    return { b, c, d, e, f, g in fun(a, b, c, d, e, f, g) }
}

/// Applies the first argument to a 8-ary function, returning a 7-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the first argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the first argument is fixed to the value of the provided argument.
public func |><A, B, C, D, E, F, G, H, I>(_ a : A, _ fun : @escaping (A, B, C, D, E, F, G, H) -> I) -> (B, C, D, E, F, G, H) -> I {
    return { b, c, d, e, f, g, h in fun(a, b, c, d, e, f, g, h) }
}

