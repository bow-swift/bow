import SwiftCheck
import Bow
import BowGenerators

public class HashableKLaws<F: HashableK & ArbitraryK, A: Arbitrary & Hashable> {
    
    public static func check() {
        coherenceWithEquality()
    }
    
    private static func coherenceWithEquality() {
        property("Equal objects have equal hash") <~ forAll { (fa1: KindOf<F, A>, fa2: KindOf<F, A>) in
            return (fa1.value == fa2.value) ==> {
                var hasher1 = Hasher()
                var hasher2 = Hasher()
                fa1.value.hash(into: &hasher1)
                fa2.value.hash(into: &hasher2)
                return hasher1.finalize() == hasher2.finalize()
            }
        }
    }
}
