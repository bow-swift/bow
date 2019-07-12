import Bow
import SwiftCheck

public class MonoidLaws<A: Monoid & Equatable & Arbitrary> {
    public static func check() {
        leftIdentity()
        rightIdentity()
    }
    
    private static func leftIdentity() {
        property("Left identity") <~ forAll { (a: A) in
            return A.empty().combine(a) == a
        }
    }
    
    private static func rightIdentity() {
        property("Right identity") <~ forAll { (a: A) in
            return a.combine(A.empty()) == a
        }
    }
}
