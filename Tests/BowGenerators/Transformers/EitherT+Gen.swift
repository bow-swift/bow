import Bow
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `EitherT`

extension EitherTPartial: ArbitraryK where F: ArbitraryK, L: Arbitrary {
    public static func generate<A: Arbitrary>() -> Kind<EitherTPartial<F, L>, A> {
        return EitherT(F.generate())
    }
}
