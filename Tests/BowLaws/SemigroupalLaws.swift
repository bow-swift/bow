import Bow
import BowGenerators
import SwiftCheck

public final class SemigroupalLaws<F: Semigroupal & ArbitraryK & EquatableK> {
	public static func check(
		isEqual: @escaping (Kind<F, ((Int, Int), Int)>, Kind<F, (Int, (Int, Int))>) -> Bool
	) {
        associativity(isEqual: isEqual)
	}
	
	private static func associativity(
        isEqual: @escaping (Kind<F, ((Int, Int), Int)>, Kind<F, (Int, (Int, Int))>) -> Bool
	) {
        property("Associativity") <~ forAll { (fa: KindOf<F, Int>, fb: KindOf<F, Int>, fc: KindOf<F, Int>) in
            isEqual(fa.value.product(fb.value).product(fc.value),
                    fa.value.product(fb.value.product(fc.value)))
        }
	}
}
