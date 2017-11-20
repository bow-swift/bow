//
//  Try.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 4/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public enum TryError : Error {
    case illegalState
    case predicateError(String)
    case unsupportedOperation(String)
}

public class TryF {}

public class Try<A> : HK<TryF, A> {
    public static func success(_ value : A) -> Try<A> {
        return Success<A>(value)
    }
    
    public static func failure(_ error : Error) -> Try<A> {
        return Failure<A>(error)
    }
    
    public static func pure(_ value : A) -> Try<A> {
        return success(value)
    }
    
    public static func raise(_ error : Error) -> Try<A> {
        return failure(error)
    }
    
    public static func invoke(_ f : () throws -> A) -> Try<A> {
        do {
            let result = try f()
            return success(result)
        } catch let error {
            return failure(error)
        }
    }
    
    public static func tailRecM<B>(_ a : A, _ f : (A) -> Try<Either<A, B>>) -> Try<B> {
        return f(a).fold(Try<B>.raise,
                         { either in
                            either.fold({ a in tailRecM(a, f)},
                                        Try<B>.pure)
                         })
    }
    
    public static func ev(_ fa : HK<TryF, A>) -> Try<A> {
        return fa.ev()
    }
    
    public func fold<B>(_ fe : (Error) -> B, _ fa : (A) throws -> B) -> B {
        switch self {
            case is Failure<A>:
                return fe((self as! Failure).error)
            case is Success<A>:
                do {
                    return try fa((self as! Success).value)
                } catch let error {
                    return fe(error)
                }
            default:
                fatalError("Try must only have Success or Failure cases")
        }
    }
    
    public func foldL<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return fold(constF(b),
                    { a in f(b, a) })
    }
    
    public func foldR<B>(_ lb : Eval<B>, _ f : (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fold(constF(lb),
                    { a in f(a, lb) })
    }
    
    public func traverse<G, B, Appl>(_ f : (A) -> HK<G, B>, _ applicative : Appl) -> HK<G, Try<B>> where Appl : Applicative, Appl.F == G {
        return fold({ _ in applicative.pure(Try<B>.raise(TryError.illegalState)) },
                    { a in applicative.map(f(a), { b in Try<B>.invoke{ b } }) })
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> Try<B> {
        return fold(Try<B>.raise, f >>> Try<B>.pure)
    }
    
    public func flatMap<B>(_ f : (A) -> Try<B>) -> Try<B> {
        return fold(Try<B>.raise, f)
    }
    
    public func ap<B>(_ ff : Try<(A) -> B>) -> Try<B> {
        return ff.flatMap(map)
    }
    
    public func filter(_ predicate : (A) -> Bool) -> Try<A> {
        return fold(Try.raise,
                    { a in predicate(a) ?
                        Try<A>.pure(a) :
                        Try<A>.raise(TryError.predicateError("Predicate does not hold for \(a)"))
                    })
    }
    
    public func failed() -> Try<Error> {
        return fold(Try<Error>.success,
                    { _ in Try<Error>.failure(TryError.unsupportedOperation("Success.failed"))})
    }
    
    public func getOrElse(_ defaultValue : A) -> A {
        return fold(constF(defaultValue), id)
    }
    
    public func recoverWith(_ f : (Error) -> Try<A>) -> Try<A> {
        return fold(f, Try.success)
    }
    
    public func recover(_ f : @escaping (Error) -> A) -> Try<A> {
        return fold(f >>> Try.success, Try.success)
    }
    
    public func transform(failure : (Error) -> Try<A>, success : (A) -> Try<A>) -> Try<A> {
        return fold(failure, { _ in flatMap(success) })
    }
}

class Success<A> : Try<A> {
    fileprivate let value : A
    
    init(_ value : A) {
        self.value = value
    }
}

class Failure<A> : Try<A> {
    fileprivate let error : Error
    
    init(_ error : Error) {
        self.error = error
    }
}

extension Try : CustomStringConvertible {
    public var description : String {
        return fold({ error in "Failure(\(error))" },
                    { value in "Success(\(value))" })
    }
}

public extension HK where F == TryF {
    public func ev() -> Try<A> {
        return self as! Try<A>
    }
}

public extension Try {
    public static func functor() -> TryFunctor {
        return TryFunctor()
    }
    
    public static func applicative() -> TryApplicative {
        return TryApplicative()
    }
    
    public static func monad() -> TryMonad {
        return TryMonad()
    }
    
    public static func monadError() -> TryMonadError {
        return TryMonadError()
    }
    
    public static func eq<EqA>(_ eqa : EqA) -> TryEq<A, EqA> {
        return TryEq<A, EqA>(eqa)
    }
}

public class TryFunctor : Functor {
    public typealias F = TryF
    
    public func map<A, B>(_ fa: HK<TryF, A>, _ f: @escaping (A) -> B) -> HK<TryF, B> {
        return fa.ev().map(f)
    }
}

public class TryApplicative : TryFunctor, Applicative {
    public func pure<A>(_ a: A) -> HK<TryF, A> {
        return Try<A>.pure(a)
    }
    
    public func ap<A, B>(_ fa: HK<TryF, A>, _ ff: HK<TryF, (A) -> B>) -> HK<TryF, B> {
        return fa.ev().ap(ff.ev())
    }
}

public class TryMonad : TryApplicative, Monad {
    public func flatMap<A, B>(_ fa: HK<TryF, A>, _ f: @escaping (A) -> HK<TryF, B>) -> HK<TryF, B> {
        return fa.ev().flatMap({ a in f(a).ev() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> HK<TryF, Either<A, B>>) -> HK<TryF, B> {
        return Try<A>.tailRecM(a, { a in f(a).ev() })
    }
}

public class TryMonadError : TryMonad, MonadError {
    public typealias E = Error
    
    public func raiseError<A>(_ e: Error) -> HK<TryF, A> {
        return Try<A>.failure(e)
    }
    
    public func handleErrorWith<A>(_ fa: HK<TryF, A>, _ f: @escaping (Error) -> HK<TryF, A>) -> HK<TryF, A> {
        return fa.ev().recoverWith({ e in f(e).ev() })
    }
}

public class TryEq<R, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = HK<TryF, R>
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: HK<TryF, R>, _ b: HK<TryF, R>) -> Bool {
        let a = Try.ev(a)
        let b = Try.ev(b)
        return a.fold({ aError in b.fold({ bError in "\(aError)" == "\(bError)" }, constF(false))},
                      { aSuccess in b.fold(constF(false), { bSuccess in eqr.eqv(aSuccess, bSuccess)})})
    }
}
