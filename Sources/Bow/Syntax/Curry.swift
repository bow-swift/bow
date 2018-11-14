import Foundation

public func curry<A, B, C>(_ fun : @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in fun(a, b) }}
}

public func uncurry<A, B, C>(_ fun : @escaping (A) -> (B) -> C) -> (A, B) -> C {
    return { a, b in fun(a)(b) }
}

public func curry<A, B, C, D>(_ fun : @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in { b in { c in fun(a,b,c) } } }
}

public func uncurry<A, B, C, D>(_ fun : @escaping (A) -> (B) -> (C) -> D) -> (A, B, C) -> D {
    return { a, b, c in fun(a)(b)(c) }
}

public func curry<A, B, C, D, E>(_ fun : @escaping (A, B, C, D) -> E) -> (A) -> (B) -> (C) -> (D) -> E {
    return { a in { b in { c in { d in fun(a,b,c,d) } } } }
}

public func uncurry<A, B, C, D, E>(_ fun : @escaping (A) -> (B) -> (C) -> (D) -> E) -> (A, B, C, D) -> E {
    return { a, b, c, d in fun(a)(b)(c)(d) }
}

public func curry<A, B, C, D, E, F>(_ fun : @escaping (A, B, C, D, E) -> F) -> (A) -> (B) -> (C) -> (D) -> (E) -> F {
    return { a in { b in { c in { d in { e in fun(a,b,c,d,e) } } } } }
}

public func uncurry<A, B, C, D, E, F>(_ fun : @escaping (A) -> (B) -> (C) -> (D) -> (E) -> F) -> (A, B, C, D, E) -> F {
    return { a, b, c, d, e in fun(a)(b)(c)(d)(e) }
}

public func curry<A, B, C, D, E, F, G>(_ fun : @escaping (A, B, C, D, E, F) -> G) -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> G {
    return { a in { b in { c in { d in { e in { f in fun(a,b,c,d,e,f) } } } } } }
}

public func uncurry<A, B, C, D, E, F, G>(_ fun : @escaping (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> G) -> (A, B, C, D, E, F) -> G {
    return { a, b, c, d, e, f in fun(a)(b)(c)(d)(e)(f) }
}

public func curry<A, B, C, D, E, F, G, H>(_ fun : @escaping (A, B, C, D, E, F, G) -> H) -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> H {
    return { a in { b in { c in { d in { e in { f in { g in fun(a,b,c,d,e,f,g) } } } } } } }
}

public func uncurry<A, B, C, D, E, F, G, H>(_ fun : @escaping (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> H) -> (A, B, C, D, E, F, G) -> H {
    return { a, b, c, d, e, f, g in fun(a)(b)(c)(d)(e)(f)(g) }
}
