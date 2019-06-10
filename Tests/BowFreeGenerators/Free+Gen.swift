import Bow
import BowFree
import BowGenerators
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `Free`

extension FreePartial: ArbitraryK where S: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<FreePartial<S>, A> {
        return Free.liftF(S.generate())
    }
}
