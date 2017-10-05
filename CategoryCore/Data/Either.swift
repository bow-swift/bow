//
//  Either.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 3/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class EitherF {}

public class Either<A, B> : HK2<EitherF, A, B> {
    public static func left(_ a : A) -> Either<A, B> {
        return Left<A, B>(a)
    }
    
    public static func right(_ b : B) -> Either<A, B> {
        return Right<A, B>(b)
    }
    
    public static func tailRecM<C>(_ a : A, _ f : (A) -> Either<C, Either<A, B>>) -> Either<C, B> {
        return f(a).fold(Either<C, B>.left,
                         { either in
                            either.fold({ left in tailRecM(left, f)},
                                        Either<C, B>.right)
                         })
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

    public func traverse<G, C, Appl>(_ f : (B) -> HK<G, C>, _ applicative : Appl) -> HK<G, Either<A, C>> where Appl : Applicative, Appl.F == G {
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
