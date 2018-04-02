//
//  ApplicativeError.swift
//  Bow
//
//  Created by Tomás Ruiz López on 29/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol ApplicativeError : Applicative {
    associatedtype E
    
    func raiseError<A>(_ e : E) -> HK<F, A>
    func handleErrorWith<A>(_ fa : HK<F, A>, _ f : @escaping (E) -> HK<F, A>) -> HK<F, A>
}

public extension ApplicativeError {
    public func handleError<A>(_ fa : HK<F, A>, _ f : @escaping (E) -> A) -> HK<F, A> {
        return handleErrorWith(fa, { a in self.pure(f(a)) })
    }
    
    public func attempt<A>(_ fa : HK<F, A>) -> HK<F, Either<E, A>> {
        return handleErrorWith(map(fa, Either<E, A>.right), { e in self.pure(Either<E, A>.left(e)) })
    }
    
    public func fromEither<A>(_ fea : Either<E, A>) -> HK<F, A> {
        return fea.fold(raiseError, pure)
    }
    
    public func catchError<A>(_ f : () throws -> A, recover : (Error) -> E) -> HK<F, A> {
        do {
            return pure(try f())
        } catch {
            return raiseError(recover(error))
        }
    }
    
    public func catchError<A>(_ f : () throws -> A) -> HK<F, A> where Self.E == Error {
        do {
            return pure(try f())
        } catch {
            return raiseError(error)
        }
    }
}
