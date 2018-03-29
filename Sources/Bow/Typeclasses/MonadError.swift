//
//  MonadError.swift
//  Bow
//
//  Created by Tomás Ruiz López on 29/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol MonadError : Monad, ApplicativeError {}

public extension MonadError {
    public func ensure<A>(_ fa : HK<F, A>, error : @escaping () -> E, predicate : @escaping (A) -> Bool) -> HK<F, A> {
        return flatMap(fa, { a in
            predicate(a) ? self.pure(a) : self.raiseError(error())
        })
    }
}
