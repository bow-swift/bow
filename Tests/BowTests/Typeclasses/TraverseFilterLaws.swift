import SwiftCheck
@testable import Bow

class TraverseFilterLaws<F> {
    static func check<TravFilt, Appl, EqA>(traverseFilter : TravFilt, applicative : Appl, eq : EqA) where TravFilt : TraverseFilter, TravFilt.F == F, Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Kind<F, Int>> {
        identityTraverseFilter(traverseFilter, applicative, eq)
        filterAConsistentWithTraverseFilter(traverseFilter, applicative, eq)
    }
    
    private static func identityTraverseFilter<TravFilt, Appl, EqA>(_ traverseFilter : TravFilt, _ applicative : Appl, _ eq : EqA) where TravFilt : TraverseFilter, TravFilt.F == F, Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Kind<F, Int>> {
        property("identity traverse filter") <- forAll { (x : Int) in
            let input = applicative.pure(x)
            return eq.eqv(traverseFilter.traverseFilter(input, { a in applicative.pure(Maybe<Int>.some(a)) }, applicative),
                          applicative.pure(input))
        }
    }
    
    private static func filterAConsistentWithTraverseFilter<TravFilt, Appl, EqA>(_ traverseFilter : TravFilt, _ applicative : Appl, _ eq : EqA) where TravFilt : TraverseFilter, TravFilt.F == F, Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Kind<F, Int>> {
        property("filterA consistent with traverseFilter") <- forAll { (x : Int, bool : Bool) in
            let input = applicative.pure(x)
            let f = { (_ : Int) in applicative.pure(bool) }
            return eq.eqv(traverseFilter.filterA(input, f, applicative),
                          traverseFilter.traverseFilter(input, { a in applicative.map(f(a)){ b in b ? Maybe<Int>.some(a) : Maybe<Int>.none()} }, applicative))
        }
    }
}
