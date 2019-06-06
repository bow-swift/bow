import Bow
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `Store`

extension StorePartial: ArbitraryK where S: CoArbitrary & Hashable & Arbitrary {
    public static func generate<A>() -> Kind<StorePartial<S>, A> where A : Arbitrary {
        return Store(state: S.arbitrary.generate, render: ArrowOf<S, A>.arbitrary.generate.getArrow)
    }
}
