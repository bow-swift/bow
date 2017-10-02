//
//  MonadFilter.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 29/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol MonadFilter : Monad, FunctorFilter {
    func empty<A>() -> HK<F, A>
}

public extension MonadFilter {
    public func mapFilter<A, B>(_ fa: HK<F, A>, _ f: @escaping (A) -> B?) -> HK<F, B> {
        return flatMap(fa, { a in
            if let b = f(a) {
                return self.pure(b)
            } else {
                return self.empty()
            }
        })
    }
}
