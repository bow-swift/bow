import SwiftCheck
import Bow
import BowOptics

public class SetterLaws<A: Equatable & Arbitrary, B: Equatable & Arbitrary & CoArbitrary & Hashable> {
    
    public static func check(setter: Setter<A, B>) {
        setIdempotent(setter)
        modifyId(setter)
        composeModify(setter)
        consistentSetModify(setter)
    }
    
    private static func setIdempotent(_ setter: Setter<A, B>) {
        property("Set idempotent") <- forAll { (a: A, b: B) in
            return setter.set(setter.set(a, b), b) == setter.set(a, b)
        }
    }
    
    private static func modifyId(_ setter: Setter<A, B>) {
        property("Modify id") <- forAll { (a: A) in
            return setter.modify(a, id) == a
        }
    }
    
    private static func composeModify(_ setter: Setter<A, B>) {
        property("Compose modify") <- forAll { (a: A, f: ArrowOf<B, B>, g: ArrowOf<B, B>) in
            return setter.modify(setter.modify(a, f.getArrow), g.getArrow) == setter.modify(a, g.getArrow <<< f.getArrow)
        }
    }
    
    private static func consistentSetModify(_ setter: Setter<A, B>) {
        property("Consistent set - modify") <- forAll { (a: A, b: B) in
            return setter.set(a, b) == setter.modify(a, constant(b))
        }
    }
}
