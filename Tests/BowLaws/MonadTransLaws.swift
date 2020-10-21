import SwiftCheck
import Bow
import BowGenerators
import XCTest

public class MonadTransLaws<T, A, B> where T: MonadTrans & EquatableK,
                                           T.F: ArbitraryK,
                                           A: Hashable & Arbitrary & CoArbitrary,
                                           B: Equatable & Arbitrary {
    public static func check() {
        liftMapsPureToPure()
        liftDistributesOverFlatMap()
    }

    private static func liftMapsPureToPure() {
        property("Lift maps pure to pure") <~ forAll { (a: B) in
            T.liftF(T.F.pure(a))
                ==
            T.pure(a)
        }
    }

    private static func liftDistributesOverFlatMap() {
        property("Lift distributes over flatMap") <~ forAll { (fa: KindOf<T.F, A>, arrow: ArrowOf<A, KindOf<T.F, B>>) in
            let f = { arrow.getArrow($0).value }
            return T.liftF(T.F.flatMap(fa.value, f))
                        ==
                   T.flatMap(T.liftF(fa.value), T.liftF <<< f)
        }
    }
}
