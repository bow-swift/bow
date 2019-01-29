import Foundation

/// Negates a boolean value.
///
/// - Parameter a: Value to be negated.
/// - Returns: `true` if the input was `false`; `false`, otherwise.
public func not(_ a : Bool) -> Bool {
    return !a
}

/// Conjunction of two boolean values.
///
/// - Parameters:
///   - a: Left-hand side value.
///   - b: Right-hand side value.
/// - Returns: `true` if both inputs are `true`, or `false` otherwise.
public func and(_ a : Bool, _ b : Bool) -> Bool {
    return a && b
}

/// Disjunction of two boolean values.
///
/// - Parameters:
///   - a: Left-hand side value.
///   - b: Right-hand side value.
/// - Returns: `false` if both inputs are `false`, or `true` otherwise.
public func or(_ a : Bool, _ b : Bool) -> Bool {
    return a || b
}

/// Exclusive or of two boolean values.
///
/// - Parameters:
///   - a: Left-hand side value.
///   - b: Right-hand side value.
/// - Returns: `true` if both inputs have different truth value, or `false` if they are equal.
public func xor(_ a : Bool, _ b : Bool) -> Bool {
    return a != b
}

/// Given a 0-ary function, provides a 0-ary function that returns the complement boolean value.
///
/// - Parameter ff: Function to be complemented.
/// - Returns: Function that returns the negated result of `ff`.
public func complement(_ ff : @escaping () -> Bool) -> () -> Bool {
    return ff >>> not
}

/// Given a 1-ary function, provides a 1-ary function that returns the complement boolean value.
///
/// - Parameters:
///   - ff: Function to be complemented.
///   - a: 1st argument of `ff`.
/// - Returns: Function that returns the negated result of `ff`.
public func complement<A>(_ ff : @escaping (_ a: A) -> Bool) -> (A) -> Bool {
    return ff >>> not
}

/// Given a 2-ary function, provides a 2-ary function that returns the complement boolean value.
///
/// - Parameters:
///   - ff: Function to be complemented.
///   - a: 1st argument of `ff`.
///   - b: 2nd argument of `ff`.
/// - Returns: Function that returns the negated result of `ff`.
public func complement<A, B>(_ ff : @escaping (_ a: A, _ b: B) -> Bool) -> (A, B) -> Bool {
    return { a, b in !ff(a, b) }
}

/// Given a 3-ary function, provides a 3-ary function that returns the complement boolean value.
///
/// - Parameters:
///   - ff: Function to be complemented.
///   - a: 1st argument of `ff`.
///   - b: 2nd argument of `ff`.
///   - c: 3rd argument of `ff`.
/// - Returns: Function that returns the negated result of `ff`.
public func complement<A, B, C>(_ ff : @escaping (_ a: A, _ b: B, _ c: C) -> Bool) -> (A, B, C) -> Bool {
    return { a, b, c in !ff(a, b, c) }
}

/// Given a 4-ary function, provides a 4-ary function that returns the complement boolean value.
///
/// - Parameters:
///   - ff: Function to be complemented.
///   - a: 1st argument of `ff`.
///   - b: 2nd argument of `ff`.
///   - c: 3rd argument of `ff`.
///   - d: 4th argument of `ff`.
/// - Returns: Function that returns the negated result of `ff`.
public func complement<A, B, C, D>(_ ff : @escaping (_ a: A, _ b: B, _ c: C, _ d: D) -> Bool) -> (A, B, C, D) -> Bool {
    return { a, b, c, d in !ff(a, b, c, d) }
}

/// Given a 5-ary function, provides a 5-ary function that returns the complement boolean value.
///
/// - Parameters:
///   - ff: Function to be complemented.
///   - a: 1st argument of `ff`.
///   - b: 2nd argument of `ff`.
///   - c: 3rd argument of `ff`.
///   - d: 4th argument of `ff`.
///   - e: 5th argument of `ff`.
/// - Returns: Function that returns the negated result of `ff`.
public func complement<A, B, C, D, E>(_ ff : @escaping (_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) -> Bool) -> (A, B, C, D, E) -> Bool {
    return { a, b, c, d, e in !ff(a, b, c, d, e) }
}

/// Given a 6-ary function, provides a 6-ary function that returns the complement boolean value.
///
/// - Parameters:
///   - ff: Function to be complemented.
///   - a: 1st argument of `ff`.
///   - b: 2nd argument of `ff`.
///   - c: 3rd argument of `ff`.
///   - d: 4th argument of `ff`.
///   - e: 5th argument of `ff`.
///   - f: 6th argument of `ff`.
/// - Returns: Function that returns the negated result of `ff`.
public func complement<A, B, C, D, E, F>(_ ff : @escaping (_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) -> Bool) -> (A, B, C, D, E, F) -> Bool {
    return { a, b, c, d, e, f in !ff(a, b, c, d, e, f) }
}

/// Given a 7-ary function, provides a 7-ary function that returns the complement boolean value.
///
/// - Parameters:
///   - ff: Function to be complemented.
///   - a: 1st argument of `ff`.
///   - b: 2nd argument of `ff`.
///   - c: 3rd argument of `ff`.
///   - d: 4th argument of `ff`.
///   - e: 5th argument of `ff`.
///   - f: 6th argument of `ff`.
///   - g: 7th argument of `ff`.
/// - Returns: Function that returns the negated result of `ff`.
public func complement<A, B, C, D, E, F, G>(_ ff : @escaping (_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G) -> Bool) -> (A, B, C, D, E, F, G) -> Bool {
    return { a, b, c, d, e, f, g in !ff(a, b, c, d, e, f, g) }
}

/// Given a 8-ary function, provides a 8-ary function that returns the complement boolean value.
///
/// - Parameters:
///   - ff: Function to be complemented.
///   - a: 1st argument of `ff`.
///   - b: 2nd argument of `ff`.
///   - c: 3rd argument of `ff`.
///   - d: 4th argument of `ff`.
///   - e: 5th argument of `ff`.
///   - f: 6th argument of `ff`.
///   - g: 7th argument of `ff`.
///   - h: 8th argument of `ff`.
/// - Returns: Function that returns the negated result of `ff`.
public func complement<A, B, C, D, E, F, G, H>(_ ff : @escaping (_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H) -> Bool) -> (A, B, C, D, E, F, G, H) -> Bool {
    return { a, b, c, d, e, f, g, h in !ff(a, b, c, d, e, f, g, h) }
}

/// Given a 9-ary function, provides a 9-ary function that returns the complement boolean value.
///
/// - Parameters:
///   - ff: Function to be complemented.
///   - a: 1st argument of `ff`.
///   - b: 2nd argument of `ff`.
///   - c: 3rd argument of `ff`.
///   - d: 4th argument of `ff`.
///   - e: 5th argument of `ff`.
///   - f: 6th argument of `ff`.
///   - g: 7th argument of `ff`.
///   - h: 8th argument of `ff`.
///   - i: 9th argument of `ff`.
/// - Returns: Function that returns the negated result of `ff`.
public func complement<A, B, C, D, E, F, G, H, I>(_ ff : @escaping (_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I) -> Bool) -> (A, B, C, D, E, F, G, H, I) -> Bool {
    return { a, b, c, d, e, f, g, h, i in !ff(a, b, c, d, e, f, g, h, i) }
}

/// Given a 10-ary function, provides a 10-ary function that returns the complement boolean value.
///
/// - Parameters:
///   - ff: Function to be complemented.
///   - a: 1st argument of `ff`.
///   - b: 2nd argument of `ff`.
///   - c: 3rd argument of `ff`.
///   - d: 4th argument of `ff`.
///   - e: 5th argument of `ff`.
///   - f: 6th argument of `ff`.
///   - g: 7th argument of `ff`.
///   - h: 8th argument of `ff`.
///   - i: 9th argument of `ff`.
///   - j: 10th argument of `ff`.
/// - Returns: Function that returns the negated result of `ff`.
public func complement<A, B, C, D, E, F, G, H, I, J>(_ ff : @escaping (_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I, _ j: J) -> Bool) -> (A, B, C, D, E, F, G, H, I, J) -> Bool {
    return { a, b, c, d, e, f, g, h, i, j in !ff(a, b, c, d, e, f, g, h, i, j) }
}
