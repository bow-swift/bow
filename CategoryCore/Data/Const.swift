//
//  Const.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 4/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class ConstF {}

public class Const<A, T> : HK2<ConstF, A, T> {
    private let value : A
    
    public static func pure(a : A) -> Const<A, T> {
        return Const<A, T>(a)
    }
    
    public init(_ value : A) {
        self.value = value
    }
    
    public func retag<U>() -> Const<A, U> {
        return Const<A, U>(value)
    }
    
    public func traverse<F, U, Appl>(_ f : (T) -> HK<F, U>, _ applicative : Appl) -> HK<F, Const<A, U>> where Appl : Applicative, Appl.F == F {
        return applicative.pure(retag())
    }
    
    public func traverseFilter<F, U, Appl>(_ f : (T) -> HK<F, Maybe<U>>, _ applicative : Appl) -> HK<F, Const<A, U>> where Appl : Applicative, Appl.F == F {
        return applicative.pure(retag())
    }
    
    public func combine<SemiG>(_ other : Const<A, T>, _ semigroup : SemiG) -> Const<A, T> where SemiG : Semigroup, SemiG.A == A {
        return Const<A, T>(semigroup.combine(self.value, other.value))
    }
    
    public func ap<U, SemiG>(_ ff : Const<A, (T) -> U>, _ semigroup : SemiG) -> Const<A, U> where SemiG : Semigroup, SemiG.A == A {
        return ff.retag().combine(self.retag(), semigroup)
    }
}

extension Const : CustomStringConvertible {
    public var description : String {
        return "Const(\(value))"
    }
}
