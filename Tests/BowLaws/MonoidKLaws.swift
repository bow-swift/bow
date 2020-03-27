import SwiftCheck
import Bow
import BowGenerators

public class MonoidKLaws<F: MonoidK & EquatableK & ArbitraryK> {
    public static func check() {
        leftIdentity()
        rightIdentity()
        fold()
    }
    
    private static func leftIdentity() {
        property("MonoidK left identity") <~ forAll { (fa: KindOf<F, Int>) in
            
            Kind<F, Int>.emptyK().combineK(fa.value)
                ==
            fa.value
        }
    }
    
    private static func rightIdentity() {
        property("MonoidK left identity") <~ forAll { (fa: KindOf<F, Int>) in
            
            fa.value.combineK(Kind<F, Int>.emptyK())
                ==
            fa.value
        }
    }
    
    private static func fold() {
        property("MonoidK fold") <~ forAll { (fa: KindOf<F, Int>) in
            ArrayK(fa.value).foldK()
                ==
            fa.value
        }
    }
}
