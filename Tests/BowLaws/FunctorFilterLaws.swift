import Foundation
import SwiftCheck
@testable import Bow

class FunctorFilterLaws<F> {
    
    static func check<FuncFilt, EqF>(functorFilter : FuncFilt, generator : @escaping (Int) -> Kind<F, Int>, eq : EqF) where FuncFilt : FunctorFilter, FuncFilt.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        mapFilterComposition(functorFilter, generator, eq)
        mapFilterMapConsistency(functorFilter, generator, eq)
    }
    
    private static func mapFilterComposition<FuncFilt, EqF>(_ functorFilter : FuncFilt, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqF) where FuncFilt : FunctorFilter, FuncFilt.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("MapFilter composition") <- forAll { (a : Int, b : Int, c : Int) in
            let fa = generator(a)
            let f : (Int) -> Option<Int> = arc4random_uniform(2) == 0 ? { _ in Option.pure(b) } : { _ in Option<Int>.none() }
            let g : (Int) -> Option<Int> = arc4random_uniform(2) == 0 ? { _ in Option.pure(c) } : { _ in Option<Int>.none() }
            return eq.eqv(functorFilter.mapFilter(functorFilter.mapFilter(fa, f), g),
                          functorFilter.mapFilter(fa, f >=> g ))
        }
    }
    
    private static func mapFilterMapConsistency<FuncFilt, EqF>(_ functorFilter : FuncFilt, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqF) where FuncFilt : FunctorFilter, FuncFilt.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Consistency between mapFilter and map") <- forAll { (a : Int, b : Int) in
            let fa = generator(a)
            let f : (Int) -> Int = { _ in b }
            return eq.eqv(functorFilter.mapFilter(fa, { x in Option.some(f(x)) }),
                          functorFilter.map(fa, f))
        }
    }
}
