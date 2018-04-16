//
//  MonadState.swift
//  Bow
//
//  Created by Tomás Ruiz López on 29/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol MonadState : Monad {
    associatedtype S
    
    func get() -> Kind<F, S>
    func set(_ s : S) -> Kind<F, ()>
}

public extension MonadState {
    public func state<A>(_ f : @escaping (S) -> (S, A)) -> Kind<F, A> {
        return self.flatMap(self.get(), { s in
            let result = f(s)
            return self.map(self.set(result.0), { _ in result.1 })
        })
    }
    
    public func modify(_ f : @escaping (S) -> S) -> Kind<F, ()> {
        return self.flatMap(self.get(), { s in self.set(f(s))})
    }
    
    public func inspect<A>(_ f : @escaping (S) -> A) -> Kind<F, A> {
        return self.map(self.get(), f)
    }
}
