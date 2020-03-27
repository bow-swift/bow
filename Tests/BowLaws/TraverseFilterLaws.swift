import SwiftCheck
import Bow
import BowGenerators

public class TraverseFilterLaws<F: TraverseFilter & Applicative & EquatableK & ArbitraryK> {
    public static func check() {
        identityTraverseFilter()
        filterAConsistentWithTraverseFilter()
    }
    
    private static func identityTraverseFilter() {
        property("identity traverse filter") <~ forAll { (x: Int) in
            let input = F.pure(x)
            
            return input.traverseFilter { a in
                F.pure(Option.some(a))
            }
                ==
            F.pure(input)
        }
    }
    
    private static func filterAConsistentWithTraverseFilter() {
        property("filterA consistent with traverseFilter") <~ forAll { (input: KindOf<F, Int>, bool: KindOf<F, Bool>) in
            let f = { (_ : Int) in bool.value }
            
            return input.value.filterA(f)
                ==
            input.value.traverseFilter { a in
                f(a).map { b in
                    b ? Option.some(a) : Option.none()
                }
            }
        }
    }
}
