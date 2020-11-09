import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension PairK: Arbitrary where F: ArbitraryK, G: ArbitraryK, A: Arbitrary {
    public static var arbitrary: Gen<PairK<F, G, A>> {
        Gen.from(PairKPartial.generate >>> PairK.fix)
    }
}

// MARK: Instance of ArbitraryK for PairK

extension PairKPartial: ArbitraryK where F: ArbitraryK, G: ArbitraryK {
    public static func generate<A: Arbitrary>() -> PairKOf<F, G, A> {
        PairK(F.generate(), G.generate())
    }
}
