import Foundation

infix operator |> : AdditionPrecedence

public func |><A, B>(_ a : A, _ fun : (A) -> B) -> B {
    return fun(a)
}

public func |><A, B, C>(_ a : A, _ fun : @escaping (A, B) -> C) -> (B) -> C {
    return { b in fun(a,b) }
}

public func |><A, B, C, D>(_ a : A, _ fun : @escaping (A, B, C) -> D) -> (B, C) -> D {
    return { b, c in fun(a, b, c) }
}

public func |><A, B, C, D, E>(_ a : A, _ fun : @escaping (A, B, C, D) -> E) -> (B, C, D) -> E {
    return { b, c, d in fun(a, b, c, d) }
}

public func |><A, B, C, D, E, F>(_ a : A, _ fun : @escaping (A, B, C, D, E) -> F) -> (B, C, D, E) -> F {
    return { b, c, d, e in fun(a, b, c, d, e) }
}

public func |><A, B, C, D, E, F, G>(_ a : A, _ fun : @escaping (A, B, C, D, E, F) -> G) -> (B, C, D, E, F) -> G {
    return { b, c, d, e, f in fun(a, b, c, d, e, f) }
}

public func |><A, B, C, D, E, F, G, H>(_ a : A, _ fun : @escaping (A, B, C, D, E, F, G) -> H) -> (B, C, D, E, F, G) -> H {
    return { b, c, d, e, f, g in fun(a, b, c, d, e, f, g) }
}

public func |><A, B, C, D, E, F, G, H, I>(_ a : A, _ fun : @escaping (A, B, C, D, E, F, G, H) -> I) -> (B, C, D, E, F, G, H) -> I {
    return { b, c, d, e, f, g, h in fun(a, b, c, d, e, f, g, h) }
}

