import SwiftCheck
import Bow
import BowGenerators

class EquatableKLaws<F: EquatableK & ArbitraryK, A: Arbitrary & Equatable> {
    
    static func check() {
        identityInEquality()
        commutativityInEquality()
    }
    
    private static func identityInEquality() {
        property("Identity: Every object is equal to itself") <- forAll() { (fa: KindOf<F, A>) in
            return fa.value == fa.value
        }
    }
    
    private static func commutativityInEquality() {
        property("Equality is commutative") <- forAll() { (fa: KindOf<F, A>, fb: KindOf<F, A>) in
            return (fa.value == fb.value) == (fb.value == fa.value)
        }
    }
}
