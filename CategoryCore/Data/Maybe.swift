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
        return filter(predicate >> not)
    }
    
    public func exists(_ predicate : (A) -> Bool) -> Bool {
        return fold({ false }, predicate)
    }
    
    public func forall(_ predicate : (A) -> Bool) -> Bool {
        return exists(predicate)
    }
    
    public func getOrElse(_ defaultValue : A) -> A {
        return fold({ defaultValue }, id)
    }
    
    public func orElse(_ defaultValue : Maybe<A>) -> Maybe<A> {
        return fold(constF(defaultValue), Maybe.some)
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
