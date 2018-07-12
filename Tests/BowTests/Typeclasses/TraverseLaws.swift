import SwiftCheck
@testable import Bow

class TraverseLaws<F> {
    static func check<Trav, Func, EqA>(traverse : Trav, functor : Func, generator : @escaping (Int) -> Kind<F, Int>, eq : EqA) where Trav : Traverse, Trav.F == F, Func : Functor, Func.F == F,  EqA : Eq, EqA.A == Kind<F, Int> {
        identityTraverse(traverse, functor, generator, eq)
        foldMapDerived(traverse, generator, eq)
    }
    
    private static func identityTraverse<Trav, Func, EqA>(_ traverse : Trav, _ functor : Func, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqA) where Trav : Traverse, Trav.F == F, Func : Functor, Func.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("Identity traverse") <- forAll { (x : Int, y : Int) in
            let f : (Int) -> Kind<ForId, Int> = { _ in Id<Int>(y) }
            let fa = generator(x)
            return eq.eqv(traverse.traverse(fa, f, Id<Int>.applicative()).fix().value,
                          functor.map(functor.map(fa, f), { a in a.fix().value }))
        }
    }
    
    private static func foldMapDerived<Trav, EqA>(_ traverse : Trav, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqA) where Trav : Traverse, Trav.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("foldMap derived") <- forAll { (x : Int, f : ArrowOf<Int, Int>) in
            let traversed = Const.fix(traverse.traverse(generator(x), { a in Const<Int, Int>(a) }, Const<Int, Int>.applicative(Int.sumMonoid))).value
            let mapped = traverse.foldMap(Int.sumMonoid, generator(x), f.getArrow)
            return traversed == mapped
        }
    }
}
