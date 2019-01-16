import Foundation

public typealias Unit = ()
public let unit : Unit = ()

/**
 Identity function. Returns the input without changing it.
 */
public func id<A>(_ a : A) -> A {
    return a
}

/**
 Given an input, provides a 0-ary function that always returns such value.
 */
public func constant<A>(_ a : A) -> () -> A {
    return { a }
}

/**
 Given an input, provides a 1-ary function that always returns such value.
 */
public func constant<A, B>(_ a : A) -> (B) -> A {
    return { _ in a }
}

/**
 Given an input, provides a 2-ary function that always returns such value.
 */
public func constant<A, B, C>(_ a : A) -> (B, C) -> A {
    return { _, _ in a }
}

/**
 Given an input, provides a 3-ary function that always returns such value.
 */
public func constant<A, B, C, D>(_ a : A) -> (B, C, D) -> A {
    return { _, _, _ in a }
}

/**
 Given an input, provides a 4-ary function that always returns such value.
 */
public func constant<A, B, C, D, E>(_ a : A) -> (B, C, D, E) -> A {
    return { _, _, _, _ in a }
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func compose<A, B>(_ g : @escaping (A) -> B, _ f : @escaping () -> A) -> () -> B {
    return andThen(f, g)
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func compose<A, B>(_ g : @escaping (A) throws -> B, _ f : @escaping () -> A) -> () throws -> B {
    return andThen(f, g)
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func compose<A, B>(_ g : @escaping (A) -> B, _ f : @escaping () throws -> A) -> () throws -> B {
    return andThen(f, g)
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func compose<A, B>(_ g : @escaping (A) throws -> B, _ f : @escaping () throws -> A) -> () throws -> B {
    return andThen(f, g)
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func compose<A, B, C>(_ g : @escaping (B) -> C, _ f : @escaping (A) -> B) -> (A) -> C {
    return andThen(f, g)
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func compose<A, B, C>(_ g : @escaping (B) throws -> C, _ f : @escaping (A) -> B) -> (A) throws -> C {
    return andThen(f, g)
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func compose<A, B, C>(_ g : @escaping (B) -> C, _ f : @escaping (A) throws -> B) -> (A) throws -> C {
    return andThen(f, g)
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func compose<A, B, C>(_ g : @escaping (B) throws -> C, _ f : @escaping (A) throws -> B) -> (A) throws -> C {
    return andThen(f, g)
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func andThen<A, B>(_ f : @escaping () -> A, _ g : @escaping (A) -> B) -> () -> B {
    return { g(f()) }
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func andThen<A, B>(_ f : @escaping () throws -> A, _ g : @escaping (A) -> B) -> () throws -> B {
    return { g(try f()) }
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func andThen<A, B>(_ f : @escaping () -> A, _ g : @escaping (A) throws -> B) -> () throws -> B {
    return { try g(f()) }
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func andThen<A, B>(_ f : @escaping () throws -> A, _ g : @escaping (A) throws -> B) -> () throws -> B {
    return { try g(try f()) }
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func andThen<A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) -> C) -> (A) -> C {
    return { x in g(f(x)) }
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func andThen<A, B, C>(_ f : @escaping (A) throws -> B, _ g : @escaping (B) -> C) -> (A) throws -> C {
    return { x in g(try f(x)) }
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func andThen<A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) throws -> C) -> (A) throws -> C {
    return { x in try g(f(x)) }
}

public func andThen<A, B, C>(_ f : @escaping (A) throws -> B, _ g : @escaping (B) throws -> C) -> (A) throws -> C {
    return { x in try g(try f(x)) }
}

infix operator >>> : AdditionPrecedence
infix operator <<< : AdditionPrecedence

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func >>><A, B>(_ f : @escaping () -> A, _ g : @escaping (A) -> B) -> () -> B {
    return andThen(f, g)
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func >>><A, B>(_ f : @escaping () throws -> A, _ g : @escaping (A) -> B) -> () throws -> B {
    return andThen(f, g)
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func >>><A, B>(_ f : @escaping () -> A, _ g : @escaping (A) throws -> B) -> () throws -> B {
    return andThen(f, g)
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func >>><A, B>(_ f : @escaping () throws -> A, _ g : @escaping (A) throws -> B) -> () throws -> B {
    return andThen(f, g)
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func >>><A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) -> C) -> (A) -> C {
    return andThen(f, g)
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func >>><A, B, C>(_ f : @escaping (A) throws -> B, _ g : @escaping (B) -> C) -> (A) throws -> C {
    return andThen(f, g)
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func >>><A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) throws -> C) -> (A) throws -> C {
    return andThen(f, g)
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func >>><A, B, C>(_ f : @escaping (A) throws -> B, _ g : @escaping (B) throws -> C) -> (A) throws -> C {
    return andThen(f, g)
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func <<<<A, B>(_ g : @escaping (A) -> B, _ f : @escaping () -> A) -> () -> B {
    return f >>> g
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func <<<<A, B>(_ g : @escaping (A) throws -> B, _ f : @escaping () -> A) -> () throws -> B {
    return f >>> g
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func <<<<A, B>(_ g : @escaping (A) -> B, _ f : @escaping () throws -> A) -> () throws -> B {
    return f >>> g
}

/**
 Composes a 0-ary function with a 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func <<<<A, B>(_ g : @escaping (A) throws -> B, _ f : @escaping () throws -> A) -> () throws -> B {
    return f >>> g
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func <<<<A, B, C>(_ g : @escaping (B) -> C, _ f : @escaping (A) -> B) -> (A) -> C {
    return f >>> g
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func <<<<A, B, C>(_ g : @escaping (B) throws -> C, _ f : @escaping (A) -> B) -> (A) throws -> C {
    return f >>> g
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func <<<<A, B, C>(_ g : @escaping (B) -> C, _ f : @escaping (A) throws -> B) -> (A) throws -> C {
    return f >>> g
}

/**
 Composes a 1-ary function with another 1-ary function.
 
 Returns a function that is the result of applying `g` to the output of `f`.
 */
public func <<<<A, B, C>(_ g : @escaping (B) throws -> C, _ f : @escaping (A) throws -> B) -> (A) throws -> C {
    return f >>> g
}

