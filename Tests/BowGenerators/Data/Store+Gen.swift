import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Store: Arbitrary where S: CoArbitrary & Hashable & Arbitrary, V: Arbitrary {
    public static var arbitrary: Gen<Store<S, V>> {
        return Gen.from(StorePartial.generate >>> Store.fix)
    }
}

// MARK: Instance of `ArbitraryK` for `Store`

extension StorePartial: ArbitraryK where S: CoArbitrary & Hashable & Arbitrary {
    public static func generate<A: Arbitrary>() -> Kind<StorePartial<S>, A> {
        return Store(state: S.arbitrary.generate, render: ArrowOf<S, A>.arbitrary.generate.getArrow)
    }
}
