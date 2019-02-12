import Foundation
import SwiftCheck
@testable import Bow

class FunctorFilterLaws<F: FunctorFilter & EquatableK> {
    
    static func check(generator: @escaping (Int) -> Kind<F, Int>) {
        mapFilterComposition(generator)
        mapFilterMapConsistency(generator)
    }
    
    private static func mapFilterComposition(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("MapFilter composition") <- forAll { (a: Int, b: Int, c: Int) in
            let fa = generator(a)
            let f: (Int) -> Option<Int> = arc4random_uniform(2) == 0 ? { _ in Option.some(b) } : { _ in Option<Int>.none() }
            let g: (Int) -> Option<Int> = arc4random_uniform(2) == 0 ? { _ in Option.some(c) } : { _ in Option<Int>.none() }
            return F.mapFilter(F.mapFilter(fa, f), g) == F.mapFilter(fa, { x in f(x).flatMap(g) })
        }
    }
    
    private static func mapFilterMapConsistency(_ generator : @escaping (Int) -> Kind<F, Int>) {
        property("Consistency between mapFilter and map") <- forAll { (a : Int, b : Int) in
            let fa = generator(a)
            let f: (Int) -> Int = { _ in b }
            return F.mapFilter(fa, { x in Option.some(f(x)) }) == F.map(fa, f)
        }
    }
}
