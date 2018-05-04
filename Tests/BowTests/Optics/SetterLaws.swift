import SwiftCheck
@testable import Bow

class SetterLaws<A, B> where A : Arbitrary, B : Arbitrary, B : CoArbitrary, B : Hashable {
    
    static func check<EqA>(setter : Setter<A, B>, eqA : EqA) where EqA : Eq, EqA.A == A {
        setIdempotent(setter, eqA)
        modifyId(setter, eqA)
        composeModify(setter, eqA)
        consistentSetModify(setter, eqA)
    }
    
    private static func setIdempotent<EqA>(_ setter : Setter<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Set idempotent") <- forAll { (a : A, b : B) in
            return eqA.eqv(setter.set(setter.set(a, b), b),
                           setter.set(a, b))
        }
    }
    
    private static func modifyId<EqA>(_ setter : Setter<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Modify id") <- forAll { (a : A) in
            return eqA.eqv(setter.modify(a, id), a)
        }
    }
    
    private static func composeModify<EqA>(_ setter : Setter<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Compose modify") <- forAll { (a : A, f : ArrowOf<B, B>, g : ArrowOf<B, B>) in
            return eqA.eqv(setter.modify(setter.modify(a, f.getArrow), g.getArrow),
                           setter.modify(a, g.getArrow <<< f.getArrow))
        }
    }
    
    private static func consistentSetModify<EqA>(_ setter : Setter<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Consistent set - modify") <- forAll { (a : A, b : B) in
            return eqA.eqv(setter.set(a, b),
                           setter.modify(a, constF(b)))
        }
    }
}
