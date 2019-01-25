import Foundation

/**
 Negates a boolean value.
 */
public func not(_ a : Bool) -> Bool {
    return !a
}

/**
 Conjunction of two boolean values.
 
 Returns `true` if both inputs are `true`, or `false` otherwise.
 */
public func and(_ a : Bool, _ b : Bool) -> Bool {
    return a && b
}

/**
 Disjunction of two boolean values.
 
 Returns `false` if both inputs are `false`, or `true` otherwise.
 */
public func or(_ a : Bool, _ b : Bool) -> Bool {
    return a || b
}

/**
 Exclusive or of two boolean values.
 
 Returns `true` if both inputs have different truth value, or `false` if they are equal.
 */
public func xor(_ a : Bool, _ b : Bool) -> Bool {
    return a != b
}

/**
 Given a 0-ary function, provides a 0-ary function that returns the complement boolean value.
 */
public func complement(_ ff : @escaping () -> Bool) -> () -> Bool {
    return ff >>> not
}

/**
 Given a 1-ary function, provides a 1-ary function that returns the complement boolean value.
 */
public func complement<A>(_ ff : @escaping (A) -> Bool) -> (A) -> Bool {
    return ff >>> not
}

/**
 Given a 2-ary function, provides a 2-ary function that returns the complement boolean value.
 */
public func complement<A, B>(_ ff : @escaping (A, B) -> Bool) -> (A, B) -> Bool {
    return { a, b in !ff(a, b) }
}

/**
 Given a 3-ary function, provides a 3-ary function that returns the complement boolean value.
 */
public func complement<A, B, C>(_ ff : @escaping (A, B, C) -> Bool) -> (A, B, C) -> Bool {
    return { a, b, c in !ff(a, b, c) }
}

/**
 Given a 4-ary function, provides a 4-ary function that returns the complement boolean value.
 */
public func complement<A, B, C, D>(_ ff : @escaping (A, B, C, D) -> Bool) -> (A, B, C, D) -> Bool {
    return { a, b, c, d in !ff(a, b, c, d) }
}

/**
 Given a 5-ary function, provides a 5-ary function that returns the complement boolean value.
 */
public func complement<A, B, C, D, E>(_ ff : @escaping (A, B, C, D, E) -> Bool) -> (A, B, C, D, E) -> Bool {
    return { a, b, c, d, e in !ff(a, b, c, d, e) }
}

/**
 Given a 6-ary function, provides a 6-ary function that returns the complement boolean value.
 */
public func complement<A, B, C, D, E, F>(_ ff : @escaping (A, B, C, D, E, F) -> Bool) -> (A, B, C, D, E, F) -> Bool {
    return { a, b, c, d, e, f in !ff(a, b, c, d, e, f) }
}

/**
 Given a 7-ary function, provides a 7-ary function that returns the complement boolean value.
 */
public func complement<A, B, C, D, E, F, G>(_ ff : @escaping (A, B, C, D, E, F, G) -> Bool) -> (A, B, C, D, E, F, G) -> Bool {
    return { a, b, c, d, e, f, g in !ff(a, b, c, d, e, f, g) }
}

/**
 Given a 8-ary function, provides a 8-ary function that returns the complement boolean value.
 */
public func complement<A, B, C, D, E, F, G, H>(_ ff : @escaping (A, B, C, D, E, F, G, H) -> Bool) -> (A, B, C, D, E, F, G, H) -> Bool {
    return { a, b, c, d, e, f, g, h in !ff(a, b, c, d, e, f, g, h) }
}

/**
 Given a 9-ary function, provides a 9-ary function that returns the complement boolean value.
 */
public func complement<A, B, C, D, E, F, G, H, I>(_ ff : @escaping (A, B, C, D, E, F, G, H, I) -> Bool) -> (A, B, C, D, E, F, G, H, I) -> Bool {
    return { a, b, c, d, e, f, g, h, i in !ff(a, b, c, d, e, f, g, h, i) }
}

/**
 Given a 10-ary function, provides a 10-ary function that returns the complement boolean value.
 */
public func complement<A, B, C, D, E, F, G, H, I, J>(_ ff : @escaping (A, B, C, D, E, F, G, H, I, J) -> Bool) -> (A, B, C, D, E, F, G, H, I, J) -> Bool {
    return { a, b, c, d, e, f, g, h, i, j in !ff(a, b, c, d, e, f, g, h, i, j) }
}
