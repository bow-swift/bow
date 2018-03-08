//
//  AsyncContext.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 29/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public typealias Proc<A> = (Callback<A>) throws -> Unit
public typealias Callback<A> = (Either<Error, A>) -> Unit

public protocol AsyncContext : Typeclass {
    associatedtype F
    
    func runAsync<A>(_ fa : @escaping Proc<A>) -> HK<F, A>
}

public func runAsync<F, A, AsyncC>(_ asyncContext : AsyncC, _ f : @escaping () throws -> A) -> HK<F, A> where AsyncC : AsyncContext, AsyncC.F == F {
    return asyncContext.runAsync { callback in
        do {
            callback(Either<Error, A>.right(try f()))
        } catch {
            callback(Either<Error, A>.left(error))
        }
    }
}

public func runAsyncUnsafe<F, A, AsyncC>(_ asyncContext : AsyncC, _ f : @escaping () -> Either<Error, A>) -> HK<F, A> where AsyncC : AsyncContext, AsyncC.F == F {
    return asyncContext.runAsync { callback in callback(f()) }
}
