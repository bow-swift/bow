import SwiftCheck
import Bow
import BowGenerators

class EquatableKLaws<F: EquatableK & ArbitraryK, A: Arbitrary & Equatable> {
    
    static func check() {
        identity()
        commutativity()
        transitivity()
    }
    
    private static func identity() {
        property("Identity: Every object is equal to itself") <- forAll { (fa: KindOf<F, A>) in
            return fa.value == fa.value
        }
    }
    
    private static func commutativity() {
        property("Equality is commutative") <- forAll { (fa: KindOf<F, A>, fb: KindOf<F, A>) in
            return (fa.value == fb.value) == (fb.value == fa.value)
        }
    }
    
    private static func transitivity() {
        property("Equality is transitive") <- forAll { (fa: KindOf<F, A>, fb: KindOf<F, A>, fc: KindOf<F, A>) in
            // fa == fb && fb == fc --> fa == fc
            return not((fa.value == fb.value) && (fb.value == fc.value)) || (fa.value == fc.value)
        }
    }
}
