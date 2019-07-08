import SwiftCheck
import Bow
import BowGenerators

public class TraverseFilterLaws<F: TraverseFilter & Applicative & EquatableK & ArbitraryK> {
    public static func check() {
        identityTraverseFilter()
        filterAConsistentWithTraverseFilter()
    }
    
    private static func identityTraverseFilter() {
        property("identity traverse filter") <- forAll { (x: Int) in
            let input = F.pure(x)
            return F.traverseFilter(input, { a in F.pure(Option<Int>.some(a)) }) == F.pure(input)
        }
    }
    
    private static func filterAConsistentWithTraverseFilter() {
        property("filterA consistent with traverseFilter") <- forAll { (input: KindOf<F, Int>, bool: KindOf<F, Bool>) in
            let f = { (_ : Int) in bool.value }
            return F.filterA(input.value, f) == F.traverseFilter(input.value, { a in F.map(f(a)){ b in b ? Option<Int>.some(a) : Option<Int>.none()} })
        }
    }
}
