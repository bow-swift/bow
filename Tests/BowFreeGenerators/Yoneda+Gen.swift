import Bow
import BowFree
import BowGenerators
import SwiftCheck

// MARK: Instance of Arbitrary for Yoneda

extension Yoneda: Arbitrary where F: ArbitraryK, A: Arbitrary {
    public static var arbitrary: Gen<Yoneda<F, A>> {
        KindOf<F, A>.arbitrary.map { fa in
            Yoneda<F, A>.liftYoneda(fa.value)
        }
    }
}

// MARK: Instance of ArbitrartK for Yoneda

extension YonedaPartial: ArbitraryK where F: ArbitraryK {
    public static func generate<A: Arbitrary>() -> YonedaOf<F, A> {
        Yoneda.arbitrary.generate
    }
}
