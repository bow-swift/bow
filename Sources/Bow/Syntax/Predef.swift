import Foundation

public typealias Unit = ()
public let unit : Unit = ()

public func id<A>(_ a : A) -> A {
    return a
}

public func constant<A>(_ a : A) -> () -> A {
    return { a }
}

public func constant<A, B>(_ a : A) -> (B) -> A {
    return { _ in a }
}

public func constant<A, B, C>(_ a : A) -> (B, C) -> A {
    return { _, _ in a }
}

public func constant<A, B, C, D>(_ a : A) -> (B, C, D) -> A {
    return { _, _, _ in a }
}

public func constant<A, B, C, D, E>(_ a : A) -> (B, C, D, E) -> A {
    return { _, _, _, _ in a }
}

public func compose<A, B>(_ g : @escaping (A) -> B, _ f : @escaping () -> A) -> () -> B {
    return andThen(f, g)
}

public func compose<A, B>(_ g : @escaping (A) throws -> B, _ f : @escaping () -> A) -> () throws -> B {
    return andThen(f, g)
}

public func compose<A, B>(_ g : @escaping (A) -> B, _ f : @escaping () throws -> A) -> () throws -> B {
    return andThen(f, g)
}

public func compose<A, B>(_ g : @escaping (A) throws -> B, _ f : @escaping () throws -> A) -> () throws -> B {
    return andThen(f, g)
}

public func compose<A, B, C>(_ g : @escaping (B) -> C, _ f : @escaping (A) -> B) -> (A) -> C {
    return andThen(f, g)
}

public func compose<A, B, C>(_ g : @escaping (B) throws -> C, _ f : @escaping (A) -> B) -> (A) throws -> C {
    return andThen(f, g)
}

public func compose<A, B, C>(_ g : @escaping (B) -> C, _ f : @escaping (A) throws -> B) -> (A) throws -> C {
    return andThen(f, g)
}

public func compose<A, B, C>(_ g : @escaping (B) throws -> C, _ f : @escaping (A) throws -> B) -> (A) throws -> C {
    return andThen(f, g)
}

public func andThen<A, B>(_ f : @escaping () -> A, _ g : @escaping (A) -> B) -> () -> B {
    return { g(f()) }
}

public func andThen<A, B>(_ f : @escaping () throws -> A, _ g : @escaping (A) -> B) -> () throws -> B {
    return { g(try f()) }
}

public func andThen<A, B>(_ f : @escaping () -> A, _ g : @escaping (A) throws -> B) -> () throws -> B {
    return { try g(f()) }
}

public func andThen<A, B>(_ f : @escaping () throws -> A, _ g : @escaping (A) throws -> B) -> () throws -> B {
    return { try g(try f()) }
}

public func andThen<A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) -> C) -> (A) -> C {
    return { x in g(f(x)) }
}

public func andThen<A, B, C>(_ f : @escaping (A) throws -> B, _ g : @escaping (B) -> C) -> (A) throws -> C {
    return { x in g(try f(x)) }
}

public func andThen<A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) throws -> C) -> (A) throws -> C {
    return { x in try g(f(x)) }
}

public func andThen<A, B, C>(_ f : @escaping (A) throws -> B, _ g : @escaping (B) throws -> C) -> (A) throws -> C {
    return { x in try g(try f(x)) }
}

infix operator >>> : AdditionPrecedence
infix operator <<< : AdditionPrecedence

public func >>><A, B>(_ f : @escaping () -> A, _ g : @escaping (A) -> B) -> () -> B {
    return andThen(f, g)
}

public func >>><A, B>(_ f : @escaping () throws -> A, _ g : @escaping (A) -> B) -> () throws -> B {
    return andThen(f, g)
}

public func >>><A, B>(_ f : @escaping () -> A, _ g : @escaping (A) throws -> B) -> () throws -> B {
    return andThen(f, g)
}

public func >>><A, B>(_ f : @escaping () throws -> A, _ g : @escaping (A) throws -> B) -> () throws -> B {
    return andThen(f, g)
}

public func >>><A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) -> C) -> (A) -> C {
    return andThen(f, g)
}

public func >>><A, B, C>(_ f : @escaping (A) throws -> B, _ g : @escaping (B) -> C) -> (A) throws -> C {
    return andThen(f, g)
}

public func >>><A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) throws -> C) -> (A) throws -> C {
    return andThen(f, g)
}

public func >>><A, B, C>(_ f : @escaping (A) throws -> B, _ g : @escaping (B) throws -> C) -> (A) throws -> C {
    return andThen(f, g)
}

public func <<<<A, B>(_ g : @escaping (A) -> B, _ f : @escaping () -> A) -> () -> B {
    return f >>> g
}

public func <<<<A, B>(_ g : @escaping (A) throws -> B, _ f : @escaping () -> A) -> () throws -> B {
    return f >>> g
}

public func <<<<A, B>(_ g : @escaping (A) -> B, _ f : @escaping () throws -> A) -> () throws -> B {
    return f >>> g
}

public func <<<<A, B>(_ g : @escaping (A) throws -> B, _ f : @escaping () throws -> A) -> () throws -> B {
    return f >>> g
}

public func <<<<A, B, C>(_ g : @escaping (B) -> C, _ f : @escaping (A) -> B) -> (A) -> C {
    return f >>> g
}

public func <<<<A, B, C>(_ g : @escaping (B) throws -> C, _ f : @escaping (A) -> B) -> (A) throws -> C {
    return f >>> g
}

public func <<<<A, B, C>(_ g : @escaping (B) -> C, _ f : @escaping (A) throws -> B) -> (A) throws -> C {
    return f >>> g
}

public func <<<<A, B, C>(_ g : @escaping (B) throws -> C, _ f : @escaping (A) throws -> B) -> (A) throws -> C {
    return f >>> g
}

