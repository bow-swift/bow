//
//  Const.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 4/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class ConstF {}
public typealias ConstPartial<A> = HK<ConstF, A>

public class Const<A, T> : HK2<ConstF, A, T> {
    public let value : A
    
    public static func pure(_ a : A) -> Const<A, T> {
        return Const<A, T>(a)
    }
    
    public static func ev(_ fa : HK2<ConstF, A, T>) -> Const<A, T>{
        return fa as! Const<A, T>
    }
    
    public init(_ value : A) {
        self.value = value
    }
    
    public func retag<U>() -> Const<A, U> {
        return Const<A, U>(value)
    }
    
    public func traverse<F, U, Appl>(_ f : (T) -> HK<F, U>, _ applicative : Appl) -> HK<F, HK2<ConstF, A, U>> where Appl : Applicative, Appl.F == F {
        return applicative.pure(retag())
    }
    
    public func traverseFilter<F, U, Appl>(_ f : (T) -> HK<F, Maybe<U>>, _ applicative : Appl) -> HK<F, HK2<ConstF, A, U>> where Appl : Applicative, Appl.F == F {
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

public extension Const {
    public static func functor() -> ConstFunctor<A> {
        return ConstFunctor<A>()
    }
    
    public static func applicative<Mono>(_ monoid : Mono) -> ConstApplicative<A, Mono> {
        return ConstApplicative<A, Mono>(monoid)
    }
    
    public static func semigroup<SemiG>(_ semigroup : SemiG) -> ConstSemigroup<A, T, SemiG> {
        return ConstSemigroup<A, T, SemiG>(semigroup)
    }
    
    public static func monoid<Mono>(_ monoid : Mono) -> ConstMonoid<A, T, Mono> {
        return ConstMonoid<A, T, Mono>(monoid)
    }
    
    public static func foldable() -> ConstFoldable<A> {
        return ConstFoldable<A>()
    }
    
    public static func traverse() -> ConstTraverse<A> {
        return ConstTraverse<A>()
    }
    
    public static func traverseFilter() -> ConstTraverseFilter<A> {
        return ConstTraverseFilter<A>()
    }
    
    public static func eq<EqA>(_ eqa : EqA) -> ConstEq<A, T, EqA> {
        return ConstEq<A, T, EqA>(eqa)
    }
}

public class ConstFunctor<R> : Functor {
    public typealias F = ConstPartial<R>
    
    public func map<A, B>(_ fa: HK<HK<ConstF, R>, A>, _ f: @escaping (A) -> B) -> HK<HK<ConstF, R>, B> {
        return Const.ev(fa).retag()
    }
}

public class ConstApplicative<R, Mono> : ConstFunctor<R>, Applicative where Mono : Monoid, Mono.A == R {
    private let monoid : Mono
    
    public init(_ monoid : Mono) {
        self.monoid = monoid
    }
    
    public func pure<A>(_ a: A) -> HK<HK<ConstF, R>, A> {
        return ConstMonoid(self.monoid).empty
    }
    
    public func ap<A, B>(_ fa: HK<HK<ConstF, R>, A>, _ ff: HK<HK<ConstF, R>, (A) -> B>) -> HK<HK<ConstF, R>, B> {
        return Const.ev(fa).ap(Const.ev(ff), monoid)
    }
}

public class ConstSemigroup<R, S, SemiG> : Semigroup where SemiG : Semigroup, SemiG.A == R {
    public typealias A = Const<R, S>
    private let semigroup : SemiG
    
    public init(_ semigroup : SemiG) {
        self.semigroup = semigroup
    }
    
    public func combine(_ a: Const<R, S>, _ b: Const<R, S>) -> Const<R, S> {
        return a.combine(b, semigroup)
    }
}

public class ConstMonoid<R, S, Mono> : ConstSemigroup<R, S, Mono>, Monoid where Mono : Monoid, Mono.A == R {
    private let monoid : Mono
    
    override public init(_ monoid : Mono) {
        self.monoid = monoid
        super.init(monoid)
    }
    
    public var empty: Const<R, S> {
        return Const(monoid.empty)
    }
}

public class ConstFoldable<R> : Foldable {
    public typealias F = ConstPartial<R>
    
    public func foldL<A, B>(_ fa: HK<HK<ConstF, R>, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return b
    }
    
    public func foldR<A, B>(_ fa: HK<HK<ConstF, R>, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return b
    }
}

public class ConstTraverse<R> : ConstFoldable<R>, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: HK<HK<ConstF, R>, A>, _ f: @escaping (A) -> HK<G, B>, _ applicative: Appl) -> HK<G, HK<HK<ConstF, R>, B>> where G == Appl.F, Appl : Applicative {
        return Const.ev(fa).traverse(f, applicative)
    }
}

public class ConstTraverseFilter<R> : ConstTraverse<R>, TraverseFilter {
    public func traverseFilter<A, B, G, Appl>(_ fa: HK<HK<ConstF, R>, A>, _ f: @escaping (A) -> HK<G, Maybe<B>>, _ applicative: Appl) -> HK<G, HK<HK<ConstF, R>, B>> where G == Appl.F, Appl : Applicative {
        return Const.ev(fa).traverseFilter(f, applicative)
    }
}

public class ConstEq<R, S, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = HK2<ConstF, R, S>
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: HK2<ConstF, R, S>, _ b: HK2<ConstF, R, S>) -> Bool {
        return eqr.eqv(Const.ev(a).value, Const.ev(b).value)
    }
}
