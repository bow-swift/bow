import SwiftCheck
@testable import Bow

class SetterLaws<A, B> where B : Arbitrary, B : CoArbitrary, B : Hashable {
    
    static func check<EqA>(setter : Setter<A, B>, eqA : EqA, generatorA : Gen<A>) where EqA : Eq, EqA.A == A {
        setIdempotent(setter, eqA, generatorA)
        modifyId(setter, eqA, generatorA)
        composeModify(setter, eqA, generatorA)
        consistentSetModify(setter, eqA, generatorA)
    }
    
    private static func setIdempotent<EqA>(_ setter : Setter<A, B>, _ eqA : EqA, _ generatorA : Gen<A>) where EqA : Eq, EqA.A == A {
        property("Set idempotent") <- forAll { (b : B) in
            let a = generatorA.generate
            return eqA.eqv(setter.set(setter.set(a, b), b),
                           setter.set(a, b))
        }
    }
    
    private static func modifyId<EqA>(_ setter : Setter<A, B>, _ eqA : EqA, _ generatorA : Gen<A>) where EqA : Eq, EqA.A == A {
        property("Modify id") <- forAll { (_ : Int) in
            let a = generatorA.generate
            return eqA.eqv(setter.modify(a, id), a)
        }
    }
    
    private static func composeModify<EqA>(_ setter : Setter<A, B>, _ eqA : EqA, _ generatorA : Gen<A>) where EqA : Eq, EqA.A == A {
        property("Compose modify") <- forAll { (f : ArrowOf<B, B>, g : ArrowOf<B, B>) in
            let a = generatorA.generate
            return eqA.eqv(setter.modify(setter.modify(a, f.getArrow), g.getArrow),
                           setter.modify(a, g.getArrow <<< f.getArrow))
        }
    }
    
    private static func consistentSetModify<EqA>(_ setter : Setter<A, B>, _ eqA : EqA, _ generatorA : Gen<A>) where EqA : Eq, EqA.A == A {
        property("Consistent set - modify") <- forAll { (b : B) in
            let a = generatorA.generate
            return eqA.eqv(setter.set(a, b),
                           setter.modify(a, constant(b)))
        }
    }
}
