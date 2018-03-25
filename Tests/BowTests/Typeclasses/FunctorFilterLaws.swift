//
//  FunctorFilterLaws.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 24/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import Bow

class FunctorFilterLaws<F> {
    
    static func check<FuncFilt, EqF>(functorFilter : FuncFilt, generator : @escaping (Int) -> HK<F, Int>, eq : EqF) where FuncFilt : FunctorFilter, FuncFilt.F == F, EqF : Eq, EqF.A == HK<F, Int> {
        mapFilterComposition(functorFilter, generator, eq)
        mapFilterMapConsistency(functorFilter, generator, eq)
    }
    
    private static func mapFilterComposition<FuncFilt, EqF>(_ functorFilter : FuncFilt, _ generator : @escaping (Int) -> HK<F, Int>, _ eq : EqF) where FuncFilt : FunctorFilter, FuncFilt.F == F, EqF : Eq, EqF.A == HK<F, Int> {
        property("MapFilter composition") <- forAll { (a : Int, b : Int, c : Int) in
            let fa = generator(a)
            let f : (Int) -> Maybe<Int> = arc4random_uniform(2) == 0 ? { _ in Maybe.pure(b) } : { _ in Maybe<Int>.none() }
            let g : (Int) -> Maybe<Int> = arc4random_uniform(2) == 0 ? { _ in Maybe.pure(c) } : { _ in Maybe<Int>.none() }
            return eq.eqv(functorFilter.mapFilter(functorFilter.mapFilter(fa, f), g),
                          functorFilter.mapFilter(fa, f >=> g ))
        }
    }
    
    private static func mapFilterMapConsistency<FuncFilt, EqF>(_ functorFilter : FuncFilt, _ generator : @escaping (Int) -> HK<F, Int>, _ eq : EqF) where FuncFilt : FunctorFilter, FuncFilt.F == F, EqF : Eq, EqF.A == HK<F, Int> {
        property("Consistency between mapFilter and map") <- forAll { (a : Int, b : Int) in
            let fa = generator(a)
            let f : (Int) -> Int = { _ in b }
            return eq.eqv(functorFilter.mapFilter(fa, { x in Maybe.some(f(x)) }),
                          functorFilter.map(fa, f))
        }
    }
}
