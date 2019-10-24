import Bow
import BowGenerators
import SwiftCheck

public final class DivideLaws<F: Divide & ArbitraryK & EquatableK> {
    public static func check(
        isEqual: @escaping (Kind<F, ((Int, Int), Int)>, Kind<F, (Int, (Int, Int))>) -> Bool
    ) {
        associativity(isEqual: isEqual)
    }
    
    private static func associativity(
        isEqual: @escaping (Kind<F, ((Int, Int), Int)>, Kind<F, (Int, (Int, Int))>) -> Bool
    ) {
        func tuple<A, B>(_ a: A, _ b: B) -> (A, B) {
            (a, b)
        }
        
        property("Divide - Associativity") <~ forAll { (fa: KindOf<F, Int>) in
            let a = fa.value.divide(fa.value.divide(fa.value, tuple(_:_:)), tuple(_:_:))
            let b = F.divide(fa.value.divide(fa.value, tuple(_:_:)), fa.value, tuple(_:_:))
            return isEqual(b, a)
        }
    }
}
