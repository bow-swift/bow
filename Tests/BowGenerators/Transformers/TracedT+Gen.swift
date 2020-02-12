import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension TracedT: Arbitrary where M: Arbitrary & Hashable & CoArbitrary, W: ArbitraryK & Functor, A: Arbitrary {
    public static var arbitrary: Gen<TracedT<M, W, A>> {
        Gen.from(TracedTPartial.generate >>> TracedT.fix)
    }
}

// MARK: Instance of `ArbitraryK` for `TracedT`

extension TracedTPartial: ArbitraryK where M: Arbitrary & Hashable & CoArbitrary, W: ArbitraryK & Functor {
    
    public static func generate<A: Arbitrary>() -> TracedTOf<M, W, A> {
        TracedT(KindOf<W, ArrowOf<M, A>>.arbitrary.generate.value.map { f in f.getArrow })
    }
}
