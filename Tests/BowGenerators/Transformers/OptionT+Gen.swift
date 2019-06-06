import Bow
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `OptionT`

extension OptionTPartial: ArbitraryK where F: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<OptionTPartial<F>, A> {
        return OptionT(F.generate())
    }
}
