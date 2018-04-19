import Foundation

func curry<A, B, C>(_ fun : @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in fun(a, b) }}
}

func uncurry<A, B, C>(_ fun : @escaping (A) -> (B) -> C) -> (A, B) -> C {
    return { a, b in fun(a)(b) }
}

func curry<A, B, C, D>(_ fun : @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in { b in { c in fun(a,b,c) } } }
}

func uncurry<A, B, C, D>(_ fun : @escaping (A) -> (B) -> (C) -> D) -> (A, B, C) -> D {
    return { a, b, c in fun(a)(b)(c) }
}

func curry<A, B, C, D, E>(_ fun : @escaping (A, B, C, D) -> E) -> (A) -> (B) -> (C) -> (D) -> E {
    return { a in { b in { c in { d in fun(a,b,c,d) } } } }
}

func uncurry<A, B, C, D, E>(_ fun : @escaping (A) -> (B) -> (C) -> (D) -> E) -> (A, B, C, D) -> E {
    return { a, b, c, d in fun(a)(b)(c)(d) }
}

func curry<A, B, C, D, E, F>(_ fun : @escaping (A, B, C, D, E) -> F) -> (A) -> (B) -> (C) -> (D) -> (E) -> F {
    return { a in { b in { c in { d in { e in fun(a,b,c,d,e) } } } } }
}

func uncurry<A, B, C, D, E, F>(_ fun : @escaping (A) -> (B) -> (C) -> (D) -> (E) -> F) -> (A, B, C, D, E) -> F {
    return { a, b, c, d, e in fun(a)(b)(c)(d)(e) }
}

func curry<A, B, C, D, E, F, G>(_ fun : @escaping (A, B, C, D, E, F) -> G) -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> G {
    return { a in { b in { c in { d in { e in { f in fun(a,b,c,d,e,f) } } } } } }
}

func uncurry<A, B, C, D, E, F, G>(_ fun : @escaping (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> G) -> (A, B, C, D, E, F) -> G {
    return { a, b, c, d, e, f in fun(a)(b)(c)(d)(e)(f) }
}

func curry<A, B, C, D, E, F, G, H>(_ fun : @escaping (A, B, C, D, E, F, G) -> H) -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> H {
    return { a in { b in { c in { d in { e in { f in { g in fun(a,b,c,d,e,f,g) } } } } } } }
}

func uncurry<A, B, C, D, E, F, G, H>(_ fun : @escaping (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> H) -> (A, B, C, D, E, F, G) -> H {
    return { a, b, c, d, e, f, g in fun(a)(b)(c)(d)(e)(f)(g) }
}
