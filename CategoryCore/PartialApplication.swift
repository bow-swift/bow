//
//  PartialApplication.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 28/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

infix operator |> : AdditionPrecedence

public func |><A, B>(_ a : A, _ fun : (A) -> B) -> B {
    return fun(a)
}

public func |><A, B, C>(_ a : A, _ fun : @escaping (A, B) -> C) -> (B) -> C {
    return { b in fun(a,b) }
}

public func |><A, B, C>(_ x : (A, B), _ fun : (A, B) -> C) -> C {
    return fun(x.0, x.1)
}

public func |><A, B, C, D>(_ a : A, _ fun : @escaping (A, B, C) -> D) -> (B, C) -> D {
    return { b, c in fun(a, b, c) }
}

public func |><A, B, C, D>(_ x : (A, B), _ fun : @escaping (A, B, C) -> D) -> (C) -> D {
    return { c in fun(x.0, x.1, c) }
}

public func |><A, B, C, D>(_ x : (A, B, C), _ fun : (A, B, C) -> D) -> D {
    return fun(x.0, x.1, x.2)
}

public func |><A, B, C, D, E>(_ a : A, _ fun : @escaping (A, B, C, D) -> E) -> (B, C, D) -> E {
    return { b, c, d in fun(a, b, c, d) }
}

public func |><A, B, C, D, E>(_ x : (A, B), _ fun : @escaping (A, B, C, D) -> E) -> (C, D) -> E {
    return { c, d in fun(x.0, x.1, c, d) }
}

public func |><A, B, C, D, E>(_ x : (A, B, C), _ fun : @escaping (A, B, C, D) -> E) -> (D) -> E {
    return { d in fun(x.0, x.1, x.2, d) }
}

public func |><A, B, C, D, E>(_ x : (A, B, C, D), _ fun : (A, B, C, D) -> E) -> E {
    return fun(x.0, x.1, x.2, x.3)
}

public func |><A, B, C, D, E, F>(_ a : A, _ fun : @escaping (A, B, C, D, E) -> F) -> (B, C, D, E) -> F {
    return { b, c, d, e in fun(a, b, c, d, e) }
}

public func |><A, B, C, D, E, F>(_ x : (A, B), _ fun : @escaping (A, B, C, D, E) -> F) -> (C, D, E) -> F {
    return { c, d, e in fun(x.0, x.1, c, d, e) }
}

public func |><A, B, C, D, E, F>(_ x : (A, B, C), _ fun : @escaping (A, B, C, D, E) -> F) -> (D, E) -> F {
    return { d, e in fun(x.0, x.1, x.2, d, e) }
}

public func |><A, B, C, D, E, F>(_ x : (A, B, C, D), _ fun : @escaping (A, B, C, D, E) -> F) -> (E) -> F {
    return { e in fun(x.0, x.1, x.2, x.3, e) }
}

public func |><A, B, C, D, E, F>(_ x : (A, B, C, D, E), _ fun : (A, B, C, D, E) -> F) -> F {
    return fun(x.0, x.1, x.2, x.3, x.4)
}

public func |><A, B, C, D, E, F, G>(_ a : A, _ fun : @escaping (A, B, C, D, E, F) -> G) -> (B, C, D, E, F) -> G {
    return { b, c, d, e, f in fun(a, b, c, d, e, f) }
}

public func |><A, B, C, D, E, F, G>(_ x : (A, B), _ fun : @escaping (A, B, C, D, E, F) -> G) -> (C, D, E, F) -> G {
    return { c, d, e, f in fun(x.0, x.1, c, d, e, f) }
}

public func |><A, B, C, D, E, F, G>(_ x : (A, B, C), _ fun : @escaping (A, B, C, D, E, F) -> G) -> (D, E, F) -> G {
    return { d, e, f in fun(x.0, x.1, x.2, d, e, f) }
}

public func |><A, B, C, D, E, F, G>(_ x : (A, B, C, D), _ fun : @escaping (A, B, C, D, E, F) -> G) -> (E, F) -> G {
    return { e, f in fun(x.0, x.1, x.2, x.3, e, f) }
}

public func |><A, B, C, D, E, F, G>(_ x : (A, B, C, D, E), _ fun : @escaping (A, B, C, D, E, F) -> G) -> (F) -> G {
    return { f in fun(x.0, x.1, x.2, x.3, x.4, f) }
}

public func |><A, B, C, D, E, F, G>(_ x : (A, B, C, D, E, F), _ fun : (A, B, C, D, E, F) -> G) -> G {
    return fun(x.0, x.1, x.2, x.3, x.4, x.5)
}

public func |><A, B, C, D, E, F, G, H>(_ a : A, _ fun : @escaping (A, B, C, D, E, F, G) -> H) -> (B, C, D, E, F, G) -> H {
    return { b, c, d, e, f, g in fun(a, b, c, d, e, f, g) }
}

public func |><A, B, C, D, E, F, G, H>(_ x : (A, B), _ fun : @escaping (A, B, C, D, E, F, G) -> H) -> (C, D, E, F, G) -> H {
    return { c, d, e, f, g in fun(x.0, x.1, c, d, e, f, g) }
}

public func |><A, B, C, D, E, F, G, H>(_ x : (A, B, C), _ fun : @escaping (A, B, C, D, E, F, G) -> H) -> (D, E, F, G) -> H {
    return { d, e, f, g in fun(x.0, x.1, x.2, d, e, f, g) }
}

public func |><A, B, C, D, E, F, G, H>(_ x : (A, B, C, D), _ fun : @escaping (A, B, C, D, E, F, G) -> H) -> (E, F, G) -> H {
    return { e, f, g in fun(x.0, x.1, x.2, x.3, e, f, g) }
}

public func |><A, B, C, D, E, F, G, H>(_ x : (A, B, C, D, E), _ fun : @escaping (A, B, C, D, E, F, G) -> H) -> (F, G) -> H {
    return { f, g in fun(x.0, x.1, x.2, x.3, x.4, f, g) }
}

public func |><A, B, C, D, E, F, G, H>(_ x : (A, B, C, D, E, F), _ fun : @escaping (A, B, C, D, E, F, G) -> H) -> (G) -> H {
    return { g in fun(x.0, x.1, x.2, x.3, x.4, x.5, g) }
}

public func |><A, B, C, D, E, F, G, H>(_ x : (A, B, C, D, E, F, G), _ fun : (A, B, C, D, E, F, G) -> H) -> H {
    return fun(x.0, x.1, x.2, x.3, x.4, x.5, x.6)
}

public func |><A, B, C, D, E, F, G, H, I>(_ a : A, _ fun : @escaping (A, B, C, D, E, F, G, H) -> I) -> (B, C, D, E, F, G, H) -> I {
    return { b, c, d, e, f, g, h in fun(a, b, c, d, e, f, g, h) }
}

public func |><A, B, C, D, E, F, G, H, I>(_ x : (A, B), _ fun : @escaping (A, B, C, D, E, F, G, H) -> I) -> (C, D, E, F, G, H) -> I {
    return { c, d, e, f, g, h in fun(x.0, x.1, c, d, e, f, g, h) }
}

public func |><A, B, C, D, E, F, G, H, I>(_ x : (A, B, C), _ fun : @escaping (A, B, C, D, E, F, G, H) -> I) -> (D, E, F, G, H) -> I {
    return { d, e, f, g, h in fun(x.0, x.1, x.2, d, e, f, g, h) }
}

public func |><A, B, C, D, E, F, G, H, I>(_ x : (A, B, C, D), _ fun : @escaping (A, B, C, D, E, F, G, H) -> I) -> (E, F, G, H) -> I {
    return { e, f, g, h in fun(x.0, x.1, x.2, x.3, e, f, g, h) }
}

public func |><A, B, C, D, E, F, G, H, I>(_ x : (A, B, C, D, E), _ fun : @escaping (A, B, C, D, E, F, G, H) -> I) -> (F, G, H) -> I {
    return { f, g, h in fun(x.0, x.1, x.2, x.3, x.4, f, g, h) }
}

public func |><A, B, C, D, E, F, G, H, I>(_ x : (A, B, C, D, E, F), _ fun : @escaping (A, B, C, D, E, F, G, H) -> I) -> (G, H) -> I {
    return { g, h in fun(x.0, x.1, x.2, x.3, x.4, x.5, g, h) }
}

public func |><A, B, C, D, E, F, G, H, I>(_ x : (A, B, C, D, E, F, G), _ fun : @escaping (A, B, C, D, E, F, G, H) -> I) -> (H) -> I {
    return { h in fun(x.0, x.1, x.2, x.3, x.4, x.5, x.6, h) }
}

public func |><A, B, C, D, E, F, G, H, I>(_ x : (A, B, C, D, E, F, G, H), _ fun : (A, B, C, D, E, F, G, H) -> I) -> I {
    return fun(x.0, x.1, x.2, x.3, x.4, x.5, x.6, x.7)
}
