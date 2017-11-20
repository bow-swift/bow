//
//  Either.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 3/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public typealias EitherPartial<A> = HK<EitherF, A>
public class EitherF {}

public class Either<A, B> : HK2<EitherF, A, B> {
    public static func left(_ a : A) -> Either<A, B> {
        return Left<A, B>(a)
    }
    
    public static func right(_ b : B) -> Either<A, B> {
        return Right<A, B>(b)
    }
    
    public static func pure(_ b : B) -> Either<A, B> {
        return right(b)
    }
    
    public static func tailRecM<C>(_ a : A, _ f : (A) -> HK<EitherPartial<C>, Either<A, B>>) -> Either<C, B> {
        return Either<C, Either<A, B>>.ev(f(a)).fold(Either<C, B>.left,
            { either in
                either.fold({ left in tailRecM(left, f)},
                            Either<C, B>.right)
            })
    }
    
    public static func ev(_ fa : HK2<EitherF, A, B>) -> Either<A, B> {
        return fa as! Either<A, B>
    }
    
    public func fold<C>(_ fa : (A) -> C, _ fb : (B) -> C) -> C {
        switch self {
            case is Left<A, B>:
                return (self as! Left<A, B>).a |> fa
            case is Right<A, B>:
                return (self as! Right<A, B>).b |> fb
            default:
                fatalError("Either must only have left and right cases")
        }
    }
    
    public var isLeft : Bool {
        return fold(constF(true), constF(false))
    }
    
    public var isRight : Bool {
        return !isLeft
    }
    
    public func foldL<C>(_ c : C, _ f : (C, B) -> C) -> C {
        return fold(constF(c), { b in f(c, b) })
    }
    
    public func foldR<C>(_ c : Eval<C>, _ f : (B, Eval<C>) -> Eval<C>) -> Eval<C> {
        return fold(constF(c), { b in f(b, c) })
    }
    
    public func swap() -> Either<B, A> {
        return fold(Either<B, A>.right, Either<B, A>.left)
    }
    
    public func map<C>(_ f : (B) -> C) -> Either<A, C> {
        return fold(Either<A, C>.left,
                    { b in Either<A, C>.right(f(b)) })
    }
    
    public func bimap<C, D>(_ fa : (A) -> C, _ fb : (B) -> D) -> Either<C, D> {
        return fold({ a in Either<C, D>.left(fa(a)) },
                    { b in Either<C, D>.right(fb(b)) })
    }
    
    public func ap<C>(_ ff : Either<A, (B) -> C>) -> Either<A, C> {
        return ff.flatMap{ f in self.map(f) }
    }
    
    public func flatMap<C>(_ f : (B) -> Either<A, C>) -> Either<A, C> {
        return fold(Either<A, C>.left, f)
    }
    
    public func exists(_ predicate : (B) -> Bool) -> Bool {
        return fold(constF(false), predicate)
    }
    
    public func toMaybe() -> Maybe<B> {
        return fold(constF(Maybe<B>.none()), Maybe<B>.some)
    }
    
    public func getOrElse(_ defaultValue : B) -> B {
        return fold(constF(defaultValue), id)
    }
    
    public func filterOrElse(_ predicate : @escaping (B) -> Bool, _ defaultValue : A) -> Either<A, B> {
        return fold(Either<A, B>.left,
                    { b in predicate(b) ?
                        Either<A, B>.right(b) :
                        Either<A, B>.left(defaultValue) })
    }

    public func traverse<G, C, Appl>(_ f : (B) -> HK<G, C>, _ applicative : Appl) -> HK<G, HK<EitherPartial<A>, C>> where Appl : Applicative, Appl.F == G {
        return fold({ a in applicative.pure(Either<A, C>.left(a)) },
                    { b in applicative.map(f(b), { c in Either<A, C>.right(c) }) })
    }
    
    public func combineK(_ y : Either<A, B>) -> Either<A, B> {
        return fold(constF(y), Either<A, B>.right)
    }
}

class Left<A, B> : Either<A, B> {
    fileprivate let a : A
    
    init(_ a : A) {
        self.a = a
    }
}

class Right<A, B> : Either<A, B> {
    fileprivate let b : B
    
    init(_ b : B) {
        self.b = b
    }
}

extension Either : CustomStringConvertible {
    public var description : String {
        return fold({ a in "Left(\(a))"},
                    { b in "Right(\(b))"})
    }
}

public extension Either {
    public static func functor() -> EitherApplicative<A> {
        return EitherApplicative<A>()
    }
    
    public static func applicative() -> EitherApplicative<A> {
        return EitherApplicative<A>()
    }
    
    public static func monad() -> EitherMonad<A> {
        return EitherMonad<A>()
    }
    
    public static func monadError() -> EitherMonadError<A> {
        return EitherMonadError<A>()
    }
    
    public static func foldable() -> EitherFoldable<A> {
        return EitherFoldable<A>()
    }
    
    public static func traverse() -> EitherTraverse<A> {
        return EitherTraverse<A>()
    }
    
    public static func semigroupK() -> EitherSemigroupK<A> {
        return EitherSemigroupK<A>()
    }
    
    public static func eq<EqL, EqR>(_ eql : EqL, _ eqr : EqR) -> EitherEq<A, B, EqL, EqR> {
        return EitherEq<A, B, EqL, EqR>(eql, eqr)
    }
}

public class EitherApplicative<C> : Applicative {
    public typealias F = EitherPartial<C>
    
    public func pure<A>(_ a: A) -> HK<HK<EitherF, C>, A> {
        return Either<C, A>.pure(a)
    }
    
    public func ap<A, B>(_ fa: HK<HK<EitherF, C>, A>, _ ff: HK<HK<EitherF, C>, (A) -> B>) -> HK<HK<EitherF, C>, B> {
        return Either.ev(fa).ap(Either.ev(ff))
    }
}

public class EitherMonad<C> : EitherApplicative<C>, Monad {
    public func flatMap<A, B>(_ fa: HK<HK<EitherF, C>, A>, _ f: @escaping (A) -> HK<HK<EitherF, C>, B>) -> HK<HK<EitherF, C>, B> {
        return Either.ev(fa).flatMap({ eca in Either.ev(f(eca)) })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> HK<HK<EitherF, C>, Either<A, B>>) -> HK<HK<EitherF, C>, B> {
        return Either<A, B>.tailRecM(a, f)
    }
}

public class EitherMonadError<C> : EitherMonad<C>, MonadError {
    public typealias E = C
    
    public func raiseError<A>(_ e: C) -> HK<HK<EitherF, C>, A> {
        return Either<C, A>.left(e)
    }
    
    public func handleErrorWith<A>(_ fa: HK<HK<EitherF, C>, A>, _ f: @escaping (C) -> HK<HK<EitherF, C>, A>) -> HK<HK<EitherF, C>, A> {
        return Either.ev(fa).fold(f, constF(Either.ev(fa)))
    }
}

public class EitherFoldable<C> : Foldable {
    public typealias F = EitherPartial<C>
    
    public func foldL<A, B>(_ fa: HK<HK<EitherF, C>, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return Either.ev(fa).foldL(b, f)
    }
    
    public func foldR<A, B>(_ fa: HK<HK<EitherF, C>, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Either.ev(fa).foldR(b, f)
    }
}

public class EitherTraverse<C> : EitherFoldable<C>, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: HK<HK<EitherF, C>, A>, _ f: @escaping (A) -> HK<G, B>, _ applicative: Appl) -> HK<G, HK<HK<EitherF, C>, B>> where G == Appl.F, Appl : Applicative {
        return Either.ev(fa).traverse(f, applicative)
    }
}

public class EitherSemigroupK<C> : SemigroupK {
    public typealias F = EitherPartial<C>
    
    public func combineK<A>(_ x: HK<HK<EitherF, C>, A>, _ y: HK<HK<EitherF, C>, A>) -> HK<HK<EitherF, C>, A> {
        return Either.ev(x).combineK(Either.ev(y))
    }
}

public class EitherEq<L, R, EqL, EqR> : Eq where EqL : Eq, EqL.A == L, EqR : Eq, EqR.A == R {
    public typealias A = HK2<EitherF, L, R>
    private let eql : EqL
    private let eqr : EqR
    
    public init(_ eql : EqL, _ eqr : EqR) {
        self.eql = eql
        self.eqr = eqr
    }
    
    public func eqv(_ a: HK2<EitherF, L, R>, _ b: HK2<EitherF, L, R>) -> Bool {
        return Either.ev(a).fold({ aLeft  in Either.ev(b).fold({ bLeft in eql.eqv(aLeft, bLeft) }, constF(false)) },
                                 { aRight in Either.ev(b).fold(constF(false), { bRight in eqr.eqv(aRight, bRight) }) })
    }
}
