import SwiftCheck
import Bow
import BowGenerators

public class EquatableKLaws<F: EquatableK & ArbitraryK, A: Arbitrary & Equatable> {
    
    public static func check() {
        identity()
        commutativity()
        transitivity()
    }
    
    private static func identity() {
        property("Identity: Every object is equal to itself") <~ forAll { (fa: KindOf<F, A>) in
            
            fa.value == fa.value
        }
    }
    
    private static func commutativity() {
        property("Equality is commutative") <~ forAll { (fa: KindOf<F, A>, fb: KindOf<F, A>) in
            
            (fa.value == fb.value)
                ==
            (fb.value == fa.value)
        }
    }
    
    private static func transitivity() {
        property("Equality is transitive") <~ forAll { (fa: KindOf<F, A>, fb: KindOf<F, A>, fc: KindOf<F, A>) in
            
            // fa == fb && fb == fc --> fa == fc
            not((fa.value == fb.value) && (fb.value == fc.value)) || (fa.value == fc.value)
        }
    }
}
