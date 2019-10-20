import Bow
import BowGenerators
import SwiftCheck

public final class MonoidalLaws<F: Monoidal & ArbitraryK & EquatableK> {
    public static func check(
        isEqual: @escaping (Kind<F, (Int, Int)>, Kind<F, Int>) -> Bool,
        associatveSemigroupalEqual: @escaping (Kind<F, ((Int, Int), Int)>, Kind<F, (Int, (Int, Int))>) -> Bool
    ) {
        SemigroupalLaws.check(isEqual: associatveSemigroupalEqual)
        leftIdentity(isEqual: isEqual)
        rightIdentity(isEqual: isEqual)
    }
    
    private static func leftIdentity(
        isEqual: @escaping (Kind<F, (Int, Int)>, Kind<F, Int>) -> Bool
    ) {
        property("Monoidal left identity") <~ forAll { (fa: KindOf<F, Int>) in
            isEqual(Kind<F, Int>.identity().product(fa.value),
                    Kind<F, Int>.identity())
        }
    }
    
    private static func rightIdentity(
        isEqual: @escaping (Kind<F, (Int, Int)>, Kind<F, Int>) -> Bool
    ) {
        property("Monoidal right identity") <~ forAll { (fa: KindOf<F, Int>) in
            isEqual(fa.value.product(Kind<F, Int>.identity()),
                    Kind<F, Int>.identity())
        }
    }
}

