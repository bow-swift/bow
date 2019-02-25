import SwiftCheck
@testable import Bow

class TraverseFilterLaws<F: TraverseFilter & Applicative & EquatableK> {
    static func check() {
        identityTraverseFilter()
        filterAConsistentWithTraverseFilter()
    }
    
    private static func identityTraverseFilter() {
        property("identity traverse filter") <- forAll { (x : Int) in
            let input = F.pure(x)
            return F.traverseFilter(input, { a in F.pure(Option<Int>.some(a)) }) == F.pure(input)
        }
    }
    
    private static func filterAConsistentWithTraverseFilter() {
        property("filterA consistent with traverseFilter") <- forAll { (x : Int, bool : Bool) in
            let input = F.pure(x)
            let f = { (_ : Int) in F.pure(bool) }
            return F.filterA(input, f) == F.traverseFilter(input, { a in F.map(f(a)){ b in b ? Option<Int>.some(a) : Option<Int>.none()} })
        }
    }
}
