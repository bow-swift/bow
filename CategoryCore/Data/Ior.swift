//
//  Ior.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 3/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class IorF {}

public class Ior<A, B> : HK2<IorF, A, B> {
    public static func left(_ a : A) -> Ior<A, B> {
        return IorLeft<A, B>(a)
    }
    
    public static func right(_ b : B) -> Ior<A, B> {
        return IorRight<A, B>(b)
    }
    
    public static func both(_ a : A, _ b : B) -> Ior<A, B> {
        return IorBoth<A, B>(a, b)
    }
    
    public static func fromMaybes(_ ma : Maybe<A>, _ mb : Maybe<B>) -> Maybe<Ior<A, B>> {
        return ma.fold({ mb.fold({ Maybe.none() },
                                 { b in Maybe.some(Ior.right(b))}) },
                       { a in mb.fold({ Maybe.some(Ior.left(a)) },
                                      { b in Maybe.some(Ior.both(a, b))})})
    }
    
    public func fold<C>(_ fa : (A) -> C, _ fb : (B) -> C, _ fab : (A, B) -> C) -> C {
        switch self {
            case is IorLeft<A, B>:
                return (self as! IorLeft<A, B>).a |> fa
            case is IorRight<A, B>:
                return (self as! IorRight<A, B>).b |> fb
            case is IorBoth<A, B>:
                let both = self as! IorBoth<A, B>
                return fab(both.a, both.b)
            default:
                fatalError("Ior must only have left, right or both")
        }
    }
    
    public var isLeft : Bool {
        return fold(constF(true), constF(false), constF(false))
    }
    
    public var isRight : Bool {
        return fold(constF(false), constF(true), constF(false))
    }
    
    public var isBoth : Bool {
        return fold(constF(false), constF(false), constF(true))
    }
    
    public func foldL<C>(_ c : C, _ f : (C, B) -> C) -> C {
        return fold(constF(c),
                    { b in f(c, b) },
                    { _, b in f(c, b) })
    }
    
    public func traverse<G, C, Appl>(_ f : (B) -> HK<G, C>, _ applicative : Appl) -> HK<G, Ior<A, C>> where Appl : Applicative, Appl.F == G {
        return fold({ a in applicative.pure(Ior<A, C>.left(a)) },
                    { b in applicative.map(f(b), { c in Ior<A, C>.right(c) }) },
                    { _, b in applicative.map(f(b), { c in Ior<A, C>.right(c) }) })
    }
    
    public func map<C>(_ f : (B) -> C) -> Ior<A, C> {
        return fold(Ior<A, C>.left,
                    { b in Ior<A, C>.right(f(b)) },
                    { a, b in Ior<A, C>.both(a, f(b)) })
    }
    
    public func bimap<C, D>(_ fa : (A) -> C, _ fb : (B) -> D) -> Ior<C, D> {
        return fold({ a in Ior<C, D>.left(fa(a)) },
                    { b in Ior<C, D>.right(fb(b)) },
                    { a, b in Ior<C, D>.both(fa(a), fb(b)) })
    }
    
    public func mapLeft<C>(_ f : (A) -> C) -> Ior<C, B> {
        return fold({ a in Ior<C, B>.left(f(a)) },
                    Ior<C, B>.right,
                    { a, b in Ior<C, B>.both(f(a), b) })
    }
    
    public func flatMap<C, SemiG>(_ f : (B) -> Ior<A, C>, _ semigroup : SemiG) -> Ior<A, C> where SemiG : Semigroup, SemiG.A == A {
        return fold(Ior<A, C>.left,
                    f,
                    { a, b in f(b).fold({ lft in Ior<A, C>.left(semigroup.combine(a, lft)) },
                                        { rgt in Ior<A, C>.right(rgt) },
                                        { lft, rgt in Ior<A, C>.both(semigroup.combine(a, lft), rgt) })
                    })
    }
    
    public func ap<C, SemiG>(_ ff : Ior<A, (B) -> C>, _ semigroup : SemiG) -> Ior<A, C> where SemiG : Semigroup, SemiG.A == A {
        return ff.flatMap(self.map, semigroup)
    }
    
    public func swap() -> Ior<B, A> {
        return fold(Ior<B, A>.right,
                    Ior<B, A>.left,
                    { a, b in Ior<B, A>.both(b, a) })
    }
    
    public func unwrap() -> Either<Either<A, B>, (A, B)> {
        return fold({ a in Either.left(Either.left(a)) },
                    { b in Either.left(Either.right(b)) },
                    { a, b in Either.right((a, b)) })
    }
    
    public func pad() -> (Maybe<A>, Maybe<B>) {
        return fold({ a in (Maybe.some(a), Maybe.none()) },
                    { b in (Maybe.none(), Maybe.some(b)) },
                    { a, b in (Maybe.some(a), Maybe.some(b)) })
    }
    
    public func toEither() -> Either<A, B> {
        return fold(Either.left,
                    Either.right,
                    { _, b in Either.right(b) })
    }
    
    public func toMaybe() -> Maybe<B> {
        return fold({ _ in Maybe<B>.none() },
                    { b in Maybe<B>.some(b) },
                    { _, b in Maybe<B>.some(b) })
    }
    
    public func getOrElse(_ defaultValue : B) -> B {
        return fold(constF(defaultValue),
                    id,
                    { _, b in b })
    }
}

class IorLeft<A, B> : Ior<A, B> {
    fileprivate let a : A
    
    init(_ a : A) {
        self.a = a
    }
}

class IorRight<A, B> : Ior<A, B> {
    fileprivate let b : B
    
    init(_ b : B) {
        self.b = b
    }
}

class IorBoth<A, B> : Ior<A, B> {
    fileprivate let a : A
    fileprivate let b : B
    
    init(_ a : A, _ b : B) {
        self.a = a
        self.b = b
    }
}

extension Ior : CustomStringConvertible {
    public var description : String {
        return fold({ a in "Left(\(a))" },
                    { b in "Right(\(b))" },
                    { a, b in "Both(\(a),\(b))" })
    }
}
