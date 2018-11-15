import SwiftCheck
@testable import Bow
@testable import BowOptics

class IsoLaws<A, B> where A : Arbitrary, B : Arbitrary, B : CoArbitrary, B : Hashable {
    
    static func check<EqA, EqB>(iso : Iso<A, B>, eqA : EqA, eqB : EqB) where EqA : Eq, EqA.A == A, EqB : Eq, EqB.A == B {
        roundTripOneWay(iso, eqA)
        roundTripOtherWay(iso, eqB)
        modifyIdentity(iso, eqA)
        composeModify(iso, eqA)
        consistentSetModify(iso, eqA)
        consistentModifyModifyFId(iso, eqA)
        consistentGetModifyFId(iso, eqB)
    }
    
    private static func roundTripOneWay<EqA>(_ iso : Iso<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Round trip one way") <- forAll { (a : A) in
            return eqA.eqv(iso.reverseGet(iso.get(a)), a)
        }
    }
    
    private static func roundTripOtherWay<EqB>(_ iso : Iso<A, B>, _ eqB : EqB) where EqB : Eq, EqB.A == B {
        property("Round trip other way") <- forAll { (b : B) in
            return eqB.eqv(iso.get(iso.reverseGet(b)), b)
        }
    }
    
    private static func modifyIdentity<EqA>(_ iso : Iso<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Modify identiy") <- forAll { (a : A) in
            return eqA.eqv(iso.modify(a, id), a)
        }
    }
    
    private static func composeModify<EqA>(_ iso : Iso<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Compose modify") <- forAll { (a : A, f : ArrowOf<B, B>, g : ArrowOf<B, B>) in
            return eqA.eqv(iso.modify(iso.modify(a, f.getArrow), g.getArrow), iso.modify(a, g.getArrow <<< f.getArrow))
        }
    }
    
    private static func consistentSetModify<EqA>(_ iso : Iso<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Consistent set-modify") <- forAll { (a : A, b : B) in
            return eqA.eqv(iso.set(b), iso.modify(a, constant(b)))
        }
    }
    
    private static func consistentModifyModifyFId<EqA>(_ iso : Iso<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Consistent modify - modifyF Id") <- forAll { (a : A, f : ArrowOf<B, B>) in
            return eqA.eqv(iso.modify(a, f.getArrow), iso.modifyF(Id<B>.functor(), a, { b in Id<B>.pure(f.getArrow(b)) }).fix().value)
        }
    }
    
    private static func consistentGetModifyFId<EqB>(_ iso : Iso<A, B>, _ eqB : EqB) where EqB : Eq, EqB.A == B {
        property("Consistent get - modifyF Id") <- forAll { (a : A) in
            return eqB.eqv(iso.get(a), Const<B, A>.fix(iso.modifyF(Const<B, A>.functor(), a, Const<B, B>.pure)).value)
        }
    }
}
