import SwiftCheck
@testable import Bow

class TraverseLaws<F> {
    static func check<Trav, Func, EqA>(traverse : Trav, functor : Func, generator : @escaping (Int) -> Kind<F, Int>, eq : EqA) where Trav : Traverse, Trav.F == F, Func : Functor, Func.F == F,  EqA : Eq, EqA.A == Kind<F, Int> {
        identityTraverse(traverse, functor, generator, eq)
    }
    
    private static func identityTraverse<Trav, Func, EqA>(_ traverse : Trav, _ functor : Func, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqA) where Trav : Traverse, Trav.F == F, Func : Functor, Func.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("Identity traverse") <- forAll { (x : Int, y : Int) in
            let f : (Int) -> Kind<ForId, Int> = { _ in Id<Int>(y) }
            let fa = generator(x)
            return eq.eqv(Id<Kind<F, Int>>.fix(traverse.traverse(fa, f, Id<Int>.applicative())).value,
                          functor.map(functor.map(fa, f), { a in Id<Int>.fix(a).value }))
        }
    }
}
