//
//  MonadCombine.swift
//  Bow
//
//  Created by Tomás Ruiz López on 9/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol MonadCombine : MonadFilter, Alternative {}

public extension MonadCombine {
    public func unite<G, A, Fold>(_ fga : HK<F, HK<G, A>>, _ foldable : Fold) -> HK<F, A> where Fold : Foldable, Fold.F == G {
        return flatMap(fga, { ga in foldable.foldL(ga, self.empty(), { acc, a in self.combineK(acc, self.pure(a)) })})
    }
    
    public func separate<G, A, B, Bifold>(_ fgab : HK<F, HK2<G, A, B>>, _ bifoldable : Bifold) -> (HK<F, A>, HK<F, B>) where Bifold : Bifoldable, Bifold.F == G {
        let asep = flatMap(fgab, { gab in bifoldable.bifoldMap(gab, self.pure, constF(self.empty()), self.algebra()) })
        let bsep = flatMap(fgab, { gab in bifoldable.bifoldMap(gab, constF(self.empty()), self.pure, self.algebra()) } )
        return (asep, bsep)
    }
}
