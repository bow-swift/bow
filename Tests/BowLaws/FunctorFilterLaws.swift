import SwiftCheck
import Bow
import BowGenerators

class FunctorFilterLaws<F: FunctorFilter & EquatableK & ArbitraryK> {
    
    static func check() {
        mapFilterComposition()
        mapFilterMapConsistency()
    }
    
    private static func mapFilterComposition() {
        property("MapFilter composition") <- forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, Option<Int>>, g: ArrowOf<Int, Option<Int>>) in
            return F.mapFilter(F.mapFilter(fa.value, f.getArrow), g.getArrow) == F.mapFilter(fa.value, { x in f.getArrow(x).flatMap(g.getArrow) })
        }
    }
    
    private static func mapFilterMapConsistency() {
        property("Consistency between mapFilter and map") <- forAll { (fa: KindOf<F, Int>, b: Int) in
            let f: (Int) -> Int = constant(b)
            return F.mapFilter(fa.value, { x in Option.some(f(x)) }) == F.map(fa.value, f)
        }
    }
}
