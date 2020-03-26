import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension EnvT: Arbitrary where E: Arbitrary, W: ArbitraryK, A: Arbitrary {
    public static var arbitrary: Gen<EnvT<E, W, A>> {
        Gen.from(EnvTPartial.generate >>> EnvT.fix)
    }
}

// MARK: Instance of ArbitraryK for EnvT

extension EnvTPartial: ArbitraryK where E: Arbitrary, W: ArbitraryK {
    public static func generate<A: Arbitrary>() -> EnvTOf<E, W, A> {
        EnvT(E.arbitrary.generate, W.generate())
    }
}
