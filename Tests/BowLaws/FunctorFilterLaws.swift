import SwiftCheck
import Bow
import BowGenerators

public class FunctorFilterLaws<F: FunctorFilter & EquatableK & ArbitraryK> {
    public static func check() {
        mapFilterComposition()
        mapFilterMapConsistency()
    }
    
    private static func mapFilterComposition() {
        property("MapFilter composition") <~ forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, Option<Int>>, g: ArrowOf<Int, Option<Int>>) in
            
            fa.value.mapFilter(f.getArrow).mapFilter(g.getArrow)
                ==
            fa.value.mapFilter { x in
                f.getArrow(x).flatMap(g.getArrow)
            }
        }
    }
    
    private static func mapFilterMapConsistency() {
        property("Consistency between mapFilter and map") <~ forAll { (fa: KindOf<F, Int>, b: Int) in
            let f: (Int) -> Int = constant(b)
            
            return fa.value.mapFilter { x in Option.some(f(x)) }
                ==
            fa.value.map(f)
        }
    }
}
