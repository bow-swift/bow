import Bow
import BowGenerators
import SwiftCheck

public final class DivisibleLaws<F: Divisible & ArbitraryK & EquatableK> {
    public static func check(isEqual: @escaping (Kind<F, (Int, Int)>, Kind<F, Int>) -> Bool) {
        leftIdentity(isEqual: isEqual)
        rightIdentity(isEqual: isEqual)
    }
    
    private static func leftIdentity(isEqual: @escaping (Kind<F, (Int, Int)>, Kind<F, Int>) -> Bool) {
        property("Divisible left identity") <~ forAll { (fa: KindOf<F, Int>) in
            let a = fa.value.divide(fa.value.conquer(), tuple(_:_:))
            return isEqual(a, fa.value)
        }
    }
    
    private static func rightIdentity(isEqual: @escaping (Kind<F, (Int, Int)>, Kind<F, Int>) -> Bool) {
        property("Divisible right identity") <~ forAll { (fa: KindOf<F, Int>) in
            let a = fa.value.conquer().divide(fa.value, tuple(_:_:))
            return isEqual(a, fa.value)
        }
    }

    private static func tuple<A, B>(_ a: A, _ b: B) -> (A, B) {
        (a, b)
    }
}
