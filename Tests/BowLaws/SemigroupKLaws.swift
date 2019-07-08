import SwiftCheck
import Bow
import BowGenerators

public class SemigroupKLaws<F: SemigroupK & EquatableK & ArbitraryK> {
    public static func check() {
        associative()
    }
    
    private static func associative() {
        property("SemigroupK combine is associative") <- forAll { (fa: KindOf<F, Int>, fb: KindOf<F, Int>, fc: KindOf<F, Int>) in
            return fa.value.combineK(fb.value.combineK(fc.value)) == fa.value.combineK(fb.value).combineK(fc.value)
        }
    }
}
