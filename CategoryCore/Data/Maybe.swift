//
//  Maybe.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 3/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class MaybeF {}

public class Maybe<A> : HK<MaybeF, A> {
    public static func some(_ a : A) -> Maybe<A> {
        return Some(a)
    }
    
    public static func none() -> Maybe<A> {
        return None()
    }
    
    public static func pure(_ a : A) -> Maybe<A> {
        return some(a)
    }
    
    public static func empty() -> Maybe<A> {
        return None()
    }
    
    public static func fromOption(_ a : A?) -> Maybe<A> {
        if let a = a {
            return some(a)
        } else {
            return none()
        }
    }
    
    public static func tailRecM<B>(_ a : A, _ f : (A) -> Maybe<Either<A, B>>) -> Maybe<B> {
        return f(a).fold(constF(Maybe<B>.none()),
                         { either in
                            either.fold({ left in tailRecM(left, f) },
                                        Maybe<B>.some)
                         }
        )
    }
    
    public static func ev(_ fa : HK<MaybeF, A>) -> Maybe<A> {
        return fa.ev()
    }
    
    public var isEmpty : Bool {
        return fold({ true },
                    { _ in false })
    }
    
    internal var isDefined : Bool {
        return !isEmpty
    }
    
    public func fold<B>(_ ifEmpty : () -> B, _ f : (A) -> B) -> B {
        switch self {
            case is Some<A>:
                return f((self as! Some<A>).a)
            case is None<A>:
                return ifEmpty()
            default:
                fatalError("Maybe has only two possible cases")
        }
    }
    
    public func map<B>(_ f : (A) -> B) -> Maybe<B> {
        return fold({ Maybe<B>.none() },
                    { a in Maybe<B>.some(f(a)) })
    }
    
    public func ap<B>(_ ff : Maybe<(A) -> B>) -> Maybe<B> {
        return ff.flatMap(map)
    }
    
    public func flatMap<B>(_ f : (A) -> Maybe<B>) -> Maybe<B> {
        return fold(Maybe<B>.none, f)
    }
    
    public func foldL<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return fold({ b },
                    { a in f(b, a) })
    }
    
    public func foldR<B>(_ b : Eval<B>, _ f : (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return self.fold(constF(b),
                         { a in f(a, b) })
    }
    
    public func traverse<G, B, Appl>(_ f : (A) -> HK<G, B>, _ applicative : Appl) -> HK<G, Maybe<B>> where Appl : Applicative, Appl.F == G {
        return fold({ applicative.pure(Maybe<B>.none()) },
                    { a in applicative.map(f(a), Maybe<B>.some)})
    }
    
    public func traverseFilter<G, B, Appl>(_ f : (A) -> HK<G, Maybe<B>>, _ applicative : Appl) -> HK<G, Maybe<B>> where Appl : Applicative, Appl.F == G {
        return fold({ applicative.pure(Maybe<B>.none()) }, f)
    }
    
    public func filter(_ predicate : (A) -> Bool) -> Maybe<A> {
        return fold({ Maybe<A>.none() },
                    { a in predicate(a) ? Maybe<A>.some(a) : Maybe<A>.none() })
    }
    
    public func filterNot(_ predicate : @escaping (A) -> Bool) -> Maybe<A> {
        return filter(predicate >>> not)
    }
    
    public func exists(_ predicate : (A) -> Bool) -> Bool {
        return fold({ false }, predicate)
    }
    
    public func forall(_ predicate : (A) -> Bool) -> Bool {
        return exists(predicate)
    }
    
    public func getOrElse(_ defaultValue : A) -> A {
        return getOrElse(constF(defaultValue))
    }
    
    public func getOrElse(_ defaultValue : () -> A) -> A {
        return fold(defaultValue, id)
    }
    
    public func orElse(_ defaultValue : Maybe<A>) -> Maybe<A> {
        return orElse(constF(defaultValue))
    }
    
    public func orElse(_ defaultValue : () -> Maybe<A>) -> Maybe<A> {
        return fold(defaultValue, Maybe.some)
    }
    
    public func toOption() -> A? {
        return fold({ nil }, id)
    }
}

class Some<A> : Maybe<A> {
    fileprivate let a : A
    
    init(_ a : A) {
        self.a = a
    }
}

class None<A> : Maybe<A> {}

extension Maybe : CustomStringConvertible {
    public var description : String {
        return fold({ "None" },
                    { a in "Some(\(a))" })
    }
}

public extension HK where F == MaybeF {
    public func ev() -> Maybe<A> {
        return self as! Maybe<A>
    }
}

public extension Maybe {
    public static func functor() -> MaybeFunctor {
        return MaybeFunctor()
    }
    
    public static func applicative() -> MaybeApplicative {
        return MaybeApplicative()
    }
    
    public static func monad() -> MaybeMonad {
        return MaybeMonad()
    }
    
    public static func semigroup<SemiG>(_ semigroup : SemiG) -> MaybeSemigroup<A, SemiG> {
        return MaybeSemigroup<A, SemiG>(semigroup)
    }
    
    public static func monoid<SemiG>(_ semigroup : SemiG) -> MaybeMonoid<A, SemiG> {
        return MaybeMonoid<A, SemiG>(semigroup)
    }
    
    public static func monadError() -> MaybeMonadError {
        return MaybeMonadError()
    }
    
    public static func eq<EqA>(_ eqa : EqA) -> MaybeEq<A, EqA> {
        return MaybeEq<A, EqA>(eqa)
    }
}

public class MaybeFunctor : Functor {
    public typealias F = MaybeF
    
    public func map<A, B>(_ fa: HK<MaybeF, A>, _ f: @escaping (A) -> B) -> HK<MaybeF, B> {
        return fa.ev().map(f)
    }
}

public class MaybeApplicative : MaybeFunctor, Applicative {
    public func pure<A>(_ a: A) -> HK<MaybeF, A> {
        return Maybe.pure(a)
    }
    
    public func ap<A, B>(_ fa: HK<MaybeF, A>, _ ff: HK<MaybeF, (A) -> B>) -> HK<MaybeF, B> {
        return fa.ev().ap(ff.ev())
    }
}

public class MaybeMonad : MaybeApplicative, Monad {
    public func flatMap<A, B>(_ fa: HK<MaybeF, A>, _ f: @escaping (A) -> HK<MaybeF, B>) -> HK<MaybeF, B> {
        return fa.ev().flatMap({ a in f(a).ev() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> HK<MaybeF, Either<A, B>>) -> HK<MaybeF, B> {
        return Maybe<A>.tailRecM(a, { a in f(a).ev() })
    }
}

public class MaybeSemigroup<R, SemiG> : Semigroup where SemiG : Semigroup, SemiG.A == R {
    public typealias A = HK<MaybeF, R>
    private let semigroup : SemiG
    
    public init(_ semigroup : SemiG) {
        self.semigroup = semigroup
    }
    
    public func combine(_ a: HK<MaybeF, R>, _ b: HK<MaybeF, R>) -> HK<MaybeF, R> {
        let a = Maybe.ev(a)
        let b = Maybe.ev(b)
        return a.fold(constF(b),
                      { aSome in b.fold(constF(a),
                                        { bSome in Maybe.some(semigroup.combine(aSome, bSome)) })
                      })
    }
}

public class MaybeMonoid<R, SemiG> : MaybeSemigroup<R, SemiG>, Monoid where SemiG : Semigroup, SemiG.A == R {
    public var empty : HK<MaybeF, R>{
        return Maybe<R>.none()
    }
}

public class MaybeMonadError : MaybeMonad, MonadError {
    public typealias E = Unit
    
    public func raiseError<A>(_ e: Unit) -> HK<MaybeF, A> {
        return Maybe<A>.none()
    }
    
    public func handleErrorWith<A>(_ fa: HK<MaybeF, A>, _ f: @escaping (Unit) -> HK<MaybeF, A>) -> HK<MaybeF, A> {
        return fa.ev().orElse(f(unit).ev())
    }
}

public class MaybeEq<R, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = HK<MaybeF, R>
    
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: HK<MaybeF, R>, _ b: HK<MaybeF, R>) -> Bool {
        let a = Maybe.ev(a)
        let b = Maybe.ev(b)
        return a.fold({ b.fold(constF(true), constF(false)) },
                      { aSome in b.fold(constF(false), { bSome in eqr.eqv(aSome, bSome) })})
    }
}
