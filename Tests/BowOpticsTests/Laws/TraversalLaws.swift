import SwiftCheck
@testable import Bow
@testable import BowOptics

class TraversalLaws<A, B> where B : Arbitrary, B : CoArbitrary, B : Hashable {
    
    static func check<EqA, EqB>(traversal : Traversal<A, B>, eqA : EqA, eqB : EqB, generatorA : Gen<A>) where EqA : Eq, EqA.A == A, EqB : Eq, EqB.A == B {
        headOption(traversal, Option.eq(eqB), generatorA)
        modifyGetAll(traversal, ArrayK.eq(eqB), generatorA)
        setIdempotent(traversal, eqA, generatorA)
        modifyIdentity(traversal, eqA, generatorA)
        composeModify(traversal, eqA, generatorA)
    }
    
    private static func headOption<EqB>(_ traversal : Traversal<A, B>, _ eqB : EqB, _ generatorA : Gen<A>) where EqB : Eq, EqB.A == OptionOf<B> {
        property("headOption") <- forAll { (_ : Int) in
            let a = generatorA.generate
            return eqB.eqv(traversal.headOption(a),
                          traversal.getAll(a).firstOrNone())
        }
    }
    
    private static func modifyGetAll<EqB>(_ traversal : Traversal<A, B>, _ eqB : EqB, _ generatorA : Gen<A>) where EqB : Eq, EqB.A == ArrayKOf<B> {
        property("modifyGetAll") <- forAll { (f : ArrowOf<B, B>) in
            let a = generatorA.generate
            return eqB.eqv(traversal.getAll(traversal.modify(a, f.getArrow)),
                           traversal.getAll(a).map(f.getArrow))
        }
    }
    
    private static func setIdempotent<EqA>(_ traversal : Traversal<A, B>, _ eqA : EqA, _ generatorA : Gen<A>) where EqA : Eq, EqA.A == A {
        property("setIdempotent") <- forAll { (b : B) in
            let a = generatorA.generate
            return eqA.eqv(traversal.set(traversal.set(a, b), b),
                           traversal.set(a, b))
        }
    }
    
    private static func modifyIdentity<EqA>(_ traversal : Traversal<A, B>, _ eqA : EqA, _ generatorA : Gen<A>) where EqA : Eq, EqA.A == A {
        property("modifyIdentity") <- forAll { (_ : Int) in
            let a = generatorA.generate
            return eqA.eqv(traversal.modify(a, id),
                           a)
        }
    }
    
    private static func composeModify<EqA>(_ traversal : Traversal<A, B>, _ eqA : EqA, _ generatorA : Gen<A>) where EqA : Eq, EqA.A == A {
        property("composeModify") <- forAll { (f : ArrowOf<B, B>, g : ArrowOf<B, B>) in
            let a = generatorA.generate
            return eqA.eqv(traversal.modify(traversal.modify(a, f.getArrow), g.getArrow),
                           traversal.modify(a, g.getArrow <<< f.getArrow))
        }
    }
}
