//
//  Predef.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 28/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public func id<A>(_ a : A) -> A {
    return a
}

public func compose<A, B>(_ f : @escaping () -> A, _ g : @escaping (A) -> B) -> () -> B {
    return { g(f()) }
}

public func compose<A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) -> C) -> (A) -> C {
    return { x in g(f(x)) }
}

infix operator >> : AdditionPrecedence
infix operator << : AdditionPrecedence

public func >><A, B>(_ f : @escaping () -> A, _ g : @escaping (A) -> B) -> () -> B {
    return compose(f, g)
}

public func >><A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) -> C) -> (A) -> C {
    return compose(f, g)
}

public func <<<A, B>(_ g : @escaping (A) -> B, _ f : @escaping () -> A) -> () -> B {
    return f >> g
}

public func <<<A, B, C>(_ g : @escaping (B) -> C, _ f : @escaping (A) -> B) -> (A) -> C {
    return f >> g
}

