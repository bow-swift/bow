import SwiftCheck
import Bow
import BowGenerators
import XCTest

public class ComonadTransLaws<T, A, B> where T: ComonadTrans & EquatableK & ArbitraryK,
                                             T.W: HashableK & ArbitraryK,
                                             A: Hashable & Arbitrary & CoArbitrary,
                                             B: Equatable & Arbitrary {
    public static func check() {
        lowerAndExtractEqualsLower()
        lowerDistributesOverCoflatMap()
    }

    private static func lowerAndExtractEqualsLower() {
        property("lower and extract equals lower") <~ forAll { (ta: KindOf<T, B>) in
            T.W.extract(T.lower(ta.value))
                ==
            T.extract(ta.value)
        }
    }

    private static func lowerDistributesOverCoflatMap() {
        property("Lower distributes over coflatMap") <~ forAll { (ta: KindOf<T, A>, arrow: ArrowOf<KindOf<T.W, A>, B>) in
            let f = arrow.getArrow <<< KindOf.init
            return T.lower(ta.value.coflatMap(f <<< T.lower))
                        ==
                   T.lower(ta.value).coflatMap(f)
        }
    }
}
