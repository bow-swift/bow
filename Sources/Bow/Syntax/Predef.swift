import Foundation

public typealias Unit = ()
public let unit : Unit = ()

/// Identity function.
///
/// Returns the input without changing it.
///
/// - Parameter a: A value.
/// - Returns: The value received as input, with no modifications.
public func id<A>(_ a : A) -> A {
    return a
}

/// Provides a constant function.
///
/// - Parameter a: Constant value to return.
/// - Returns: A 0-ary function that constantly return the value provided as argument.
public func constant<A>(_ a: @autoclosure @escaping () -> A) -> () -> A {
    return a
}

/// Provides a constant function.
///
/// - Parameter a: Constant value to return.
/// - Returns: A 1-ary function that constantly return the value provided as argument, regardless of its input parameter.
public func constant<A, B>(_ a: @autoclosure @escaping () -> A) -> (B) -> A {
    return { _ in return a() }
}

/// Provides a constant function.
///
/// - Parameter a: Constant value to return.
/// - Returns: A 2-ary function that constantly return the value provided as argument, regardless of its input parameters.
public func constant<A, B, C>(_ a: @autoclosure @escaping () -> A) -> (B, C) -> A {
    return { _, _ in a() }
}

/// Provides a constant function.
///
/// - Parameter a: Constant value to return.
/// - Returns: A 3-ary function that constantly return the value provided as argument, regardless of its input parameters.
public func constant<A, B, C, D>(_ a: @autoclosure @escaping () -> A) -> (B, C, D) -> A {
    return { _, _, _ in a() }
}

/// Provides a constant function.
///
/// - Parameter a: Constant value to return.
/// - Returns: A 4-ary function that constantly return the value provided as argument, regardless of its input parameters.
public func constant<A, B, C, D, E>(_ a: @autoclosure @escaping () -> A) -> (B, C, D, E) -> A {
    return { _, _, _, _ in a() }
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
public func compose<A, B>(_ g : @escaping (A) -> B, _ f : @escaping () -> A) -> () -> B {
    return andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B>(_ g : @escaping (A) throws -> B, _ f : @escaping () -> A) -> () throws -> B {
    return andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B>(_ g : @escaping (A) -> B, _ f : @escaping () throws -> A) -> () throws -> B {
    return andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B>(_ g : @escaping (A) throws -> B, _ f : @escaping () throws -> A) -> () throws -> B {
    return andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B, C>(_ g : @escaping (B) -> C, _ f : @escaping (A) -> B) -> (A) -> C {
    return andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B, C>(_ g : @escaping (B) throws -> C, _ f : @escaping (A) -> B) -> (A) throws -> C {
    return andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B, C>(_ g : @escaping (B) -> C, _ f : @escaping (A) throws -> B) -> (A) throws -> C {
    return andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func compose<A, B, C>(_ g : @escaping (B) throws -> C, _ f : @escaping (A) throws -> B) -> (A) throws -> C {
    return andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B>(_ f : @escaping () -> A, _ g : @escaping (A) -> B) -> () -> B {
    return { g(f()) }
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B>(_ f : @escaping () throws -> A, _ g : @escaping (A) -> B) -> () throws -> B {
    return { g(try f()) }
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B>(_ f : @escaping () -> A, _ g : @escaping (A) throws -> B) -> () throws -> B {
    return { try g(f()) }
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B>(_ f : @escaping () throws -> A, _ g : @escaping (A) throws -> B) -> () throws -> B {
    return { try g(try f()) }
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) -> C) -> (A) -> C {
    return { x in g(f(x)) }
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B, C>(_ f : @escaping (A) throws -> B, _ g : @escaping (B) -> C) -> (A) throws -> C {
    return { x in g(try f(x)) }
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) throws -> C) -> (A) throws -> C {
    return { x in try g(f(x)) }
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func andThen<A, B, C>(_ f : @escaping (A) throws -> B, _ g : @escaping (B) throws -> C) -> (A) throws -> C {
    return { x in try g(try f(x)) }
}

infix operator >>> : AdditionPrecedence
infix operator <<< : AdditionPrecedence

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B>(_ f : @escaping () -> A, _ g : @escaping (A) -> B) -> () -> B {
    return andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B>(_ f : @escaping () throws -> A, _ g : @escaping (A) -> B) -> () throws -> B {
    return andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B>(_ f : @escaping () -> A, _ g : @escaping (A) throws -> B) -> () throws -> B {
    return andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B>(_ f : @escaping () throws -> A, _ g : @escaping (A) throws -> B) -> () throws -> B {
    return andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) -> C) -> (A) -> C {
    return andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B, C>(_ f : @escaping (A) throws -> B, _ g : @escaping (B) -> C) -> (A) throws -> C {
    return andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) throws -> C) -> (A) throws -> C {
    return andThen(f, g)
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func >>><A, B, C>(_ f : @escaping (A) throws -> B, _ g : @escaping (B) throws -> C) -> (A) throws -> C {
    return andThen(f, g)
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B>(_ g : @escaping (A) -> B, _ f : @escaping () -> A) -> () -> B {
    return f >>> g
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B>(_ g : @escaping (A) throws -> B, _ f : @escaping () -> A) -> () throws -> B {
    return f >>> g
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B>(_ g : @escaping (A) -> B, _ f : @escaping () throws -> A) -> () throws -> B {
    return f >>> g
}

/// Composes a 0-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B>(_ g : @escaping (A) throws -> B, _ f : @escaping () throws -> A) -> () throws -> B {
    return f >>> g
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B, C>(_ g : @escaping (B) -> C, _ f : @escaping (A) -> B) -> (A) -> C {
    return f >>> g
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B, C>(_ g : @escaping (B) throws -> C, _ f : @escaping (A) -> B) -> (A) throws -> C {
    return f >>> g
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B, C>(_ g : @escaping (B) -> C, _ f : @escaping (A) throws -> B) -> (A) throws -> C {
    return f >>> g
}

/// Composes a 1-ary function with a 1-ary function.
///
/// Returns a function that is the result of applying `g` to the output of `f`.
///
/// - Parameters:
///   - g: Left-hand side of the function composition.
///   - f: Right-hand side of the function composition.
/// - Returns: A function that applies `g` to the output of `f`.
public func <<<<A, B, C>(_ g : @escaping (B) throws -> C, _ f : @escaping (A) throws -> B) -> (A) throws -> C {
    return f >>> g
}

