import SwiftCheck
@testable import Bow

class TraversalLaws<A, B> where A : Arbitrary, B : Arbitrary, B : CoArbitrary, B : Hashable {
    
    static func check<EqA, EqB>(traversal : Traversal<A, B>, eqA : EqA, eqB : EqB) where EqA : Eq, EqA.A == A, EqB : Eq, EqB.A == B {
        headMaybe(traversal, Maybe.eq(eqB))
        modifyGetAll(traversal, ListK.eq(eqB))
        setIdempotent(traversal, eqA)
        modifyIdentity(traversal, eqA)
        composeModify(traversal, eqA)
    }
    
    private static func headMaybe<EqB>(_ traversal : Traversal<A, B>, _ eqB : EqB) where EqB : Eq, EqB.A == MaybeOf<B> {
        property("headMaybe") <- forAll { (a : A) in
            return eqB.eqv(traversal.headMaybe(a),
                          traversal.getAll(a).firstOrNone())
        }
    }
    
    private static func modifyGetAll<EqB>(_ traversal : Traversal<A, B>, _ eqB : EqB) where EqB : Eq, EqB.A == ListKOf<B> {
        property("modifyGetAll") <- forAll { (a : A, f : ArrowOf<B, B>) in
            return eqB.eqv(traversal.getAll(traversal.modify(a, f.getArrow)),
                           traversal.getAll(a).map(f.getArrow))
        }
    }
    
    private static func setIdempotent<EqA>(_ traversal : Traversal<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("setIdempotent") <- forAll { (a : A, b : B) in
            return eqA.eqv(traversal.set(traversal.set(a, b), b),
                           traversal.set(a, b))
        }
    }
    
    private static func modifyIdentity<EqA>(_ traversal : Traversal<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("modifyIdentity") <- forAll { (a : A) in
            return eqA.eqv(traversal.modify(a, id),
                           a)
        }
    }
    
    private static func composeModify<EqA>(_ traversal : Traversal<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("composeModify") <- forAll { (a : A, f : ArrowOf<B, B>, g : ArrowOf<B, B>) in
            return eqA.eqv(traversal.modify(traversal.modify(a, f.getArrow), g.getArrow),
                           traversal.modify(a, g.getArrow <<< f.getArrow))
        }
    }
}
