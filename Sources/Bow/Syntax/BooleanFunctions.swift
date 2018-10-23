import Foundation

public func not(_ a : Bool) -> Bool {
    return !a
}

public func and(_ a : Bool, _ b : Bool) -> Bool {
    return a && b
}

public func or(_ a : Bool, _ b : Bool) -> Bool {
    return a || b
}

public func xor(_ a : Bool, _ b : Bool) -> Bool {
    return a != b
}

public func complement(_ ff : @escaping () -> Bool) -> () -> Bool {
    return ff >>> not
}

public func complement<A>(_ ff : @escaping (A) -> Bool) -> (A) -> Bool {
    return ff >>> not
}

public func complement<A, B>(_ ff : @escaping (A, B) -> Bool) -> (A, B) -> Bool {
    return { a, b in !ff(a, b) }
}

public func complement<A, B, C>(_ ff : @escaping (A, B, C) -> Bool) -> (A, B, C) -> Bool {
    return { a, b, c in !ff(a, b, c) }
}

public func complement<A, B, C, D>(_ ff : @escaping (A, B, C, D) -> Bool) -> (A, B, C, D) -> Bool {
    return { a, b, c, d in !ff(a, b, c, d) }
}

public func complement<A, B, C, D, E>(_ ff : @escaping (A, B, C, D, E) -> Bool) -> (A, B, C, D, E) -> Bool {
    return { a, b, c, d, e in !ff(a, b, c, d, e) }
}

public func complement<A, B, C, D, E, F>(_ ff : @escaping (A, B, C, D, E, F) -> Bool) -> (A, B, C, D, E, F) -> Bool {
    return { a, b, c, d, e, f in !ff(a, b, c, d, e, f) }
}

public func complement<A, B, C, D, E, F, G>(_ ff : @escaping (A, B, C, D, E, F, G) -> Bool) -> (A, B, C, D, E, F, G) -> Bool {
    return { a, b, c, d, e, f, g in !ff(a, b, c, d, e, f, g) }
}

public func complement<A, B, C, D, E, F, G, H>(_ ff : @escaping (A, B, C, D, E, F, G, H) -> Bool) -> (A, B, C, D, E, F, G, H) -> Bool {
    return { a, b, c, d, e, f, g, h in !ff(a, b, c, d, e, f, g, h) }
}

public func complement<A, B, C, D, E, F, G, H, I>(_ ff : @escaping (A, B, C, D, E, F, G, H, I) -> Bool) -> (A, B, C, D, E, F, G, H, I) -> Bool {
    return { a, b, c, d, e, f, g, h, i in !ff(a, b, c, d, e, f, g, h, i) }
}

public func complement<A, B, C, D, E, F, G, H, I, J>(_ ff : @escaping (A, B, C, D, E, F, G, H, I, J) -> Bool) -> (A, B, C, D, E, F, G, H, I, J) -> Bool {
    return { a, b, c, d, e, f, g, h, i, j in !ff(a, b, c, d, e, f, g, h, i, j) }
}
