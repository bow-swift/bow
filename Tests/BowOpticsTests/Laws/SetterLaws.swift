import SwiftCheck
@testable import Bow
@testable import BowOptics

class SetterLaws<A: Equatable, B: Equatable & Arbitrary & CoArbitrary & Hashable> {
    
    static func check(setter: Setter<A, B>, generatorA: Gen<A>) {
        setIdempotent(setter, generatorA)
        modifyId(setter, generatorA)
        composeModify(setter, generatorA)
        consistentSetModify(setter, generatorA)
    }
    
    private static func setIdempotent(_ setter: Setter<A, B>, _ generatorA : Gen<A>) {
        property("Set idempotent") <- forAll { (b: B) in
            let a = generatorA.generate
            return setter.set(setter.set(a, b), b) == setter.set(a, b)
        }
    }
    
    private static func modifyId(_ setter: Setter<A, B>, _ generatorA: Gen<A>) {
        property("Modify id") <- forAll { (_: Int) in
            let a = generatorA.generate
            return setter.modify(a, id) == a
        }
    }
    
    private static func composeModify(_ setter: Setter<A, B>, _ generatorA : Gen<A>) {
        property("Compose modify") <- forAll { (f: ArrowOf<B, B>, g: ArrowOf<B, B>) in
            let a = generatorA.generate
            return setter.modify(setter.modify(a, f.getArrow), g.getArrow) == setter.modify(a, g.getArrow <<< f.getArrow)
        }
    }
    
    private static func consistentSetModify(_ setter: Setter<A, B>, _ generatorA : Gen<A>) {
        property("Consistent set - modify") <- forAll { (b: B) in
            let a = generatorA.generate
            return setter.set(a, b) == setter.modify(a, constant(b))
        }
    }
}
