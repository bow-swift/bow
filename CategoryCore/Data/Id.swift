//
//  Id.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 4/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class IdF {}

public class Id<A> : HK<IdF, A> {
    private let value : A
    
    public static func pure(_ a : A) -> Id<A> {
        return Id<A>(a)
    }
    
    public init(_ value : A) {
        self.value = value
    }
    
    public func map<B>(_ f : (A) -> B) -> Id<B> {
        return Id<B>(f(value))
    }
    
    public func ap<B>(_ ff : Id<(A) -> B>) -> Id<B> {
        return ff.flatMap(map)
    }
    
    public func flatMap<B>(_ f : (A) -> Id<B>) -> Id<B> {
        return f(value)
    }
    
    public func foldL<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return f(b, value)
    }
    
    public func foldR<B>(_ b : Eval<B>, _ f : (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return f(value, b)
    }
    
    public func traverse<G, B, Appl>(_ f : (A) -> HK<G, B>, _ applicative : Appl) -> HK<G, Id<B>> where Appl : Applicative, Appl.F == G {
        return applicative.map(f(self.value), Id<B>.init)
    }
    
    public func coflatMap<B>(_ f : (Id<A>) -> B) -> Id<B> {
        return self.map{ _ in f(self) }
    }
    
    public func extract() -> A {
        return value
    }
}

extension Id : CustomStringConvertible {
    public var description : String {
        return "Id(\(value))"
    }
}
