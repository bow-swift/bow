import Bow
import BowGenerators
import SwiftCheck

public final class DivisibleLaws<F: Divisible & ArbitraryK & EquatableK> {
    public static func check(isEqual: @escaping (Kind<F, (Int, Int)>, Kind<F, Int>) -> Bool) {
        leftIdentity(isEqual: isEqual)
        rightIdentity(isEqual: isEqual)
    }
    
    private static func leftIdentity(isEqual: @escaping (Kind<F, (Int, Int)>, Kind<F, Int>) -> Bool) {
        property("Left identity") <~ forAll { (fa: KindOf<F, Int>) in
            
            isEqual(
                fa.value.divide(Kind<F, Int>.conquer(), tuple),
                fa.value)
        }
    }
    
    private static func rightIdentity(isEqual: @escaping (Kind<F, (Int, Int)>, Kind<F, Int>) -> Bool) {
        property("Right identity") <~ forAll { (fa: KindOf<F, Int>) in
            
            isEqual(
                Kind<F, Int>.conquer().divide(fa.value, tuple),
                fa.value)
        }
    }

    private static func tuple<A, B>(_ a: A, _ b: B) -> (A, B) {
        (a, b)
    }
}
