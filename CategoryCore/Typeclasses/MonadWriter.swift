//
//  MonadWriter.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 29/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol MonadWriter : Monad {
    associatedtype W
    
    func writer<A>(_ aw : (W, A)) -> HK<F, A>
    func listen<A>(_ fa : HK<F, A>) -> HK<F, (W, A)>
    func pass<A>(_ fa : HK<F, ((W) -> W, A)>) -> HK<F, A>
}

public extension MonadWriter {
    public func tell(_ w : W) -> HK<F, ()> {
        return self.writer((w, ()))
    }
    
    public func listens<A, B>(_ fa : HK<F, A>, _ f : @escaping (W) -> B) -> HK<F, (B, A)> {
        return map(self.listen(fa), { pair in (f(pair.0), pair.1) })
    }
    
    public func censor<A>(_ fa : HK<F, A>, _ f : @escaping (W) -> W) -> HK<F, A> {
        return self.flatMap(self.listen(fa), { pair in self.writer((f(pair.0), pair.1)) })
    }
}
