import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension StoreT: Arbitrary where S: CoArbitrary & Hashable & Arbitrary, W: Functor & ArbitraryK, A: Arbitrary {
    public static var arbitrary: Gen<StoreT<S, W, A>> {
        Gen.from(StoreTPartial.generate >>> StoreT.fix)
    }
}

// MARK: Instance of ArbitraryK for Store

extension StoreTPartial: ArbitraryK where S: CoArbitrary & Hashable & Arbitrary, W: Functor & ArbitraryK {
    public static func generate<A: Arbitrary>() -> StoreTOf<S, W, A> {
        StoreT(S.arbitrary.generate,
               KindOf<W, ArrowOf<S, A>>.arbitrary.generate.value.map { f in f.getArrow })
    }
}
