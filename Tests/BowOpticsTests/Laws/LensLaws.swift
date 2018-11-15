import SwiftCheck
@testable import Bow
@testable import BowOptics

class LensLaws<A, B> where A : Arbitrary, B : Arbitrary, B : CoArbitrary, B : Hashable {
    
    static func check<EqA, EqB>(lens : Lens<A, B>, eqA : EqA, eqB : EqB) where EqA : Eq, EqA.A == A, EqB : Eq, EqB.A == B {
        getSet(lens, eqA)
        setGet(lens, eqB)
        setIdempotent(lens, eqA)
        modifyId(lens, eqA)
        composeModify(lens, eqA)
        consistentSetModify(lens, eqA)
        consistentModifyModifyFId(lens, eqA)
        consistentGetModifyFId(lens, eqB)
    }
    
    private static func getSet<EqA>(_ lens : Lens<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("get set") <- forAll { (a : A) in
            return eqA.eqv(lens.set(a, lens.get(a)), a)
        }
    }
    
    private static func setGet<EqB>(_ lens : Lens<A, B>, _ eqB : EqB) where EqB : Eq, EqB.A == B {
        property("set get") <- forAll { (a : A, b : B) in
            return eqB.eqv(lens.get(lens.set(a, b)), b)
        }
    }
    
    private static func setIdempotent<EqA>(_ lens : Lens<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Set idempotent") <- forAll { (a : A, b : B) in
            return eqA.eqv(lens.set(lens.set(a, b), b), lens.set(a, b))
        }
    }
    
    private static func modifyId<EqA>(_ lens : Lens<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Modify id") <- forAll { (a : A) in
            return eqA.eqv(lens.modify(a, id), a)
        }
    }
    
    private static func composeModify<EqA>(_ lens : Lens<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Compose modify") <- forAll { (a : A, f : ArrowOf<B, B>, g : ArrowOf<B, B>) in
            return eqA.eqv(lens.modify(lens.modify(a, f.getArrow), g.getArrow),
                           lens.modify(a, g.getArrow <<< f.getArrow))
        }
    }
    
    private static func consistentSetModify<EqA>(_ lens : Lens<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Consistent set - modify") <- forAll { (a : A, b : B) in
            return eqA.eqv(lens.set(a, b),
                           lens.modify(a, constant(b)))
        }
    }
    
    private static func consistentModifyModifyFId<EqA>(_ lens : Lens<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Consistent modify - modifyF Id") <- forAll { (a : A, f : ArrowOf<B, B>) in
            return eqA.eqv(lens.modify(a, f.getArrow),
                           lens.modifyF(Id<B>.functor(), a, { b in Id.pure(f.getArrow(b)) }).fix().value)
        }
    }
    
    private static func consistentGetModifyFId<EqB>(_ lens : Lens<A, B>, _ eqB : EqB) where EqB : Eq, EqB.A == B {
        property("Consistent get - modifyF Id") <- forAll { (a : A) in
            return eqB.eqv(lens.get(a),
                           Const<B, A>.fix(lens.modifyF(Const<B, A>.functor(), a, Const<B, B>.pure)).value)
        }
    }
}
