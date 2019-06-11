import Foundation
import SwiftCheck
import Bow
import BowGenerators

class MonoidKLaws<F: MonoidK & EquatableK & ArbitraryK> {
    static func check() {
        leftIdentity()
        rightIdentity()
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
}
