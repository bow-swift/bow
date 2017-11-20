//
//  FunctorLaws.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import CategoryCore

class FunctorLaws<F> {
    static func check<Func, EqA>(functor : Func, generator : @escaping (Int) -> HK<F, Int>, eq : EqA) where Func : Functor, Func.F == F, EqA : Eq, EqA.A == HK<F, Int> {
        covariantIdentity(functor : functor,
                          generator : generator,
                          eq : eq)
        covariantComposition(functor : functor,
                             generator : generator,
                             eq : eq)
    }

    private static func covariantIdentity<Func, EqA>(functor : Func, generator : @escaping (Int) -> HK<F, Int>, eq : EqA) where Func : Functor, Func.F == F, EqA : Eq, EqA.A == HK<F, Int> {
        property("Identity is preserved under functor transformation") <- forAll() { (a : Int) in
            let fa = generator(a)
            return eq.eqv(functor.map(fa, id), id(fa))
        }
    }
    
    private static func covariantComposition<Func, EqA>(functor : Func, generator : @escaping (Int) -> HK<F, Int>, eq : EqA) where Func : Functor, Func.F == F, EqA : Eq, EqA.A == HK<F, Int> {
        property("Composition is preserverd under functor transformation") <- forAll() { (a : Int, b : Int, c : Int) in
            let f : (Int) -> Int = constF(b)
            let g : (Int) -> Int = constF(c)
            let fa = generator(a)
            return eq.eqv(functor.map(functor.map(fa, f), g), functor.map(fa, f >>> g))
        }
    }
}
