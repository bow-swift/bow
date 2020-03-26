import Foundation

public typealias Unit = ()
public let unit: Unit = ()

/// Identity function.
///
/// Returns the input without changing it.
///
/// - Parameter a: A value.
/// - Returns: The value received as input, with no modifications.
public func id<A>(_ a: A) -> A {
    a
}

/// Provides a constant function.
///
/// - Parameter a: Constant value to return.
/// - Returns: A 0-ary function that constantly return the value provided as argument.
public func constant<A>(_ a: @autoclosure @escaping () -> A) -> () -> A {
    a
}

/// Provides a constant function.
///
/// - Parameter a: Constant value to return.
/// - Returns: A 1-ary function that constantly return the value provided as argument, regardless of its input parameter.
public func constant<A, B>(_ a: @autoclosure @escaping () -> A) -> (B) -> A {
    { _ in a() }
}

/// Provides a constant function.
///
/// - Parameter a: Constant value to return.
/// - Returns: A 2-ary function that constantly return the value provided as argument, regardless of its input parameters.
public func constant<A, B, C>(_ a: @autoclosure @escaping () -> A) -> (B, C) -> A {
    { _, _ in a() }
}

/// Provides a constant function.
///
/// - Parameter a: Constant value to return.
/// - Returns: A 3-ary function that constantly return the value provided as argument, regardless of its input parameters.
public func constant<A, B, C, D>(_ a: @autoclosure @escaping () -> A) -> (B, C, D) -> A {
    { _, _, _ in a() }
}

/// Provides a constant function.
///
/// - Parameter a: Constant value to return.
/// - Returns: A 4-ary function that constantly return the value provided as argument, regardless of its input parameters.
public func constant<A, B, C, D, E>(_ a: @autoclosure @escaping () -> A) -> (B, C, D, E) -> A {
    { _, _, _, _ in a() }
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B>(_ g: @escaping (A) -> B, _ f: @escaping () -> A) -> () -> B {
    andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B>(_ g: @escaping (A) throws -> B, _ f: @escaping () -> A) -> () throws -> B {
    andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B>(_ g: @escaping (A) -> B, _ f: @escaping () throws -> A) -> () throws -> B {
    andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B>(_ g: @escaping (A) throws -> B, _ f: @escaping () throws -> A) -> () throws -> B {
    andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B, C>(_ g: @escaping (B) -> C, _ f: @escaping (A) -> B) -> (A) -> C {
    andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B, C>(_ g: @escaping (B) throws -> C, _ f: @escaping (A) -> B) -> (A) throws -> C {
    andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B, C>(_ g: @escaping (B) -> C, _ f: @escaping (A) throws -> B) -> (A) throws -> C {
    andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B, C>(_ g: @escaping (B) throws -> C, _ f: @escaping (A) throws -> B) -> (A) throws -> C {
    andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B>(_ f: @escaping () -> A, _ g: @escaping (A) -> B) -> () -> B {
    { g(f()) }
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B>(_ f: @escaping () throws -> A, _ g: @escaping (A) -> B) -> () throws -> B {
    { g(try f()) }
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B>(_ f: @escaping () -> A, _ g: @escaping (A) throws -> B) -> () throws -> B {
    { try g(f()) }
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B>(_ f: @escaping () throws -> A, _ g: @escaping (A) throws -> B) -> () throws -> B {
    { try g(try f()) }
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    { x in g(f(x)) }
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B, C>(_ f: @escaping (A) throws -> B, _ g: @escaping (B) -> C) -> (A) throws -> C {
    { x in g(try f(x)) }
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) throws -> C) -> (A) throws -> C {
    { x in try g(f(x)) }
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B, C>(_ f: @escaping (A) throws -> B, _ g: @escaping (B) throws -> C) -> (A) throws -> C {
    { x in try g(try f(x)) }
}

infix operator >>>: AdditionPrecedence
infix operator <<<: AdditionPrecedence

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B>(_ f: @escaping () -> A, _ g: @escaping (A) -> B) -> () -> B {
    andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B>(_ f: @escaping () throws -> A, _ g: @escaping (A) -> B) -> () throws -> B {
    andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B>(_ f: @escaping () -> A, _ g: @escaping (A) throws -> B) -> () throws -> B {
    andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B>(_ f: @escaping () throws -> A, _ g: @escaping (A) throws -> B) -> () throws -> B {
    andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B, C>(_ f: @escaping (A) throws -> B, _ g: @escaping (B) -> C) -> (A) throws -> C {
    andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) throws -> C) -> (A) throws -> C {
    andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B, C>(_ f: @escaping (A) throws -> B, _ g: @escaping (B) throws -> C) -> (A) throws -> C {
    andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B>(_ g: @escaping (A) -> B, _ f: @escaping () -> A) -> () -> B {
    f >>> g
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B>(_ g: @escaping (A) throws -> B, _ f: @escaping () -> A) -> () throws -> B {
    f >>> g
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B>(_ g: @escaping (A) -> B, _ f: @escaping () throws -> A) -> () throws -> B {
    f >>> g
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B>(_ g: @escaping (A) throws -> B, _ f: @escaping () throws -> A) -> () throws -> B {
    f >>> g
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B, C>(_ g: @escaping (B) -> C, _ f: @escaping (A) -> B) -> (A) -> C {
    f >>> g
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B, C>(_ g: @escaping (B) throws -> C, _ f: @escaping (A) -> B) -> (A) throws -> C {
    f >>> g
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B, C>(_ g: @escaping (B) -> C, _ f: @escaping (A) throws -> B) -> (A) throws -> C {
    f >>> g
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B, C>(_ g: @escaping (B) throws -> C, _ f: @escaping (A) throws -> B) -> (A) throws -> C {
    f >>> g
}

/// Flips the arguments of a binary function.
///
/// - Parameter f: Function whose arguments must be flipped.
/// - Returns: A function with the same behavior as the input, but with arguments flipped.
public func flip<A, B, C>(_ f: @escaping (A, B) -> C) -> (B, A) -> C {
    { b, a in f(a, b) }
}
