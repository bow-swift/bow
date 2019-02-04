import Foundation

/// Curries a 2-ary function.
///
/// - Parameter fun: Function to be curried.
/// - Returns: `fun` in curried form.
public func curry<A, B, C>(_ fun : @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in fun(a, b) }}
}

/// Uncurries a 2-ary function.
///
/// - Parameter fun: Function to be uncurried.
/// - Returns: `fun` in uncurried form.
public func uncurry<A, B, C>(_ fun : @escaping (A) -> (B) -> C) -> (A, B) -> C {
    return { a, b in fun(a)(b) }
}

/// Curries a 3-ary function.
///
/// - Parameter fun: Function to be curried.
/// - Returns: `fun` in curried form.
public func curry<A, B, C, D>(_ fun : @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in { b in { c in fun(a,b,c) } } }
}

/// Uncurries a 3-ary function.
///
/// - Parameter fun: Function to be uncurried.
/// - Returns: `fun` in uncurried form.
public func uncurry<A, B, C, D>(_ fun : @escaping (A) -> (B) -> (C) -> D) -> (A, B, C) -> D {
    return { a, b, c in fun(a)(b)(c) }
}

/// Curries a 4-ary function.
///
/// - Parameter fun: Function to be curried.
/// - Returns: `fun` in curried form.
public func curry<A, B, C, D, E>(_ fun : @escaping (A, B, C, D) -> E) -> (A) -> (B) -> (C) -> (D) -> E {
    return { a in { b in { c in { d in fun(a,b,c,d) } } } }
}

/// Uncurries a 4-ary function.
///
/// - Parameter fun: Function to be uncurried.
/// - Returns: `fun` in uncurried form.
public func uncurry<A, B, C, D, E>(_ fun : @escaping (A) -> (B) -> (C) -> (D) -> E) -> (A, B, C, D) -> E {
    return { a, b, c, d in fun(a)(b)(c)(d) }
}

/// Curries a 5-ary function.
///
/// - Parameter fun: Function to be curried.
/// - Returns: `fun` in curried form.
public func curry<A, B, C, D, E, F>(_ fun : @escaping (A, B, C, D, E) -> F) -> (A) -> (B) -> (C) -> (D) -> (E) -> F {
    return { a in { b in { c in { d in { e in fun(a,b,c,d,e) } } } } }
}

/// Uncurries a 5-ary function.
///
/// - Parameter fun: Function to be uncurried.
/// - Returns: `fun` in uncurried form.
public func uncurry<A, B, C, D, E, F>(_ fun : @escaping (A) -> (B) -> (C) -> (D) -> (E) -> F) -> (A, B, C, D, E) -> F {
    return { a, b, c, d, e in fun(a)(b)(c)(d)(e) }
}

/// Curries a 6-ary function.
///
/// - Parameter fun: Function to be curried.
/// - Returns: `fun` in curried form.
public func curry<A, B, C, D, E, F, G>(_ fun : @escaping (A, B, C, D, E, F) -> G) -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> G {
    return { a in { b in { c in { d in { e in { f in fun(a,b,c,d,e,f) } } } } } }
}

/// Uncurries a 6-ary function.
///
/// - Parameter fun: Function to be uncurried.
/// - Returns: `fun` in uncurried form.
public func uncurry<A, B, C, D, E, F, G>(_ fun : @escaping (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> G) -> (A, B, C, D, E, F) -> G {
    return { a, b, c, d, e, f in fun(a)(b)(c)(d)(e)(f) }
}

/// Curries a 7-ary function.
///
/// - Parameter fun: Function to be curried.
/// - Returns: `fun` in curried form.
public func curry<A, B, C, D, E, F, G, H>(_ fun : @escaping (A, B, C, D, E, F, G) -> H) -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> H {
    return { a in { b in { c in { d in { e in { f in { g in fun(a,b,c,d,e,f,g) } } } } } } }
}

/// Uncurries a 7-ary function.
///
/// - Parameter fun: Function to be uncurried.
/// - Returns: `fun` in uncurried form.
public func uncurry<A, B, C, D, E, F, G, H>(_ fun : @escaping (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> H) -> (A, B, C, D, E, F, G) -> H {
    return { a, b, c, d, e, f, g in fun(a)(b)(c)(d)(e)(f)(g) }
}
