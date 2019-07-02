import SwiftCheck
import Bow
import BowGenerators

class MonoidKLaws<F: MonoidK & EquatableK & ArbitraryK> {
    static func check() {
        leftIdentity()
        rightIdentity()
        fold()
    }
    
    private static func leftIdentity() {
        property("MonoidK left identity") <- forAll { (fa: KindOf<F, Int>) in
            return F.emptyK().combineK(fa.value) == fa.value
        }
    }
    
    private static func rightIdentity() {
        property("MonoidK left identity") <- forAll { (fa: KindOf<F, Int>) in
            return fa.value.combineK(F.emptyK()) == fa.value
        }
    }
    
    private static func fold() {
        property("MonoidK fold") <- forAll { (fa: KindOf<F, Int>) in
            return ArrayK(fa.value).foldK() == fa.value
        }
    }
}
