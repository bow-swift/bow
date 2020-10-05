import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Function1LazyComposition: Arbitrary where I: CoArbitrary & Hashable, O: Arbitrary {
    public static var arbitrary: Gen<Function1LazyComposition<I, O>> {
        ArrowOf<I, O>.arbitrary.map { arrow in
            Function1LazyComposition(arrow.getArrow)
        }
    }
}

// MARK: Instance of ArbitraryK for Function1

extension Function1LazyCompositionPartial: ArbitraryK where I: CoArbitrary & Hashable {
    public static func generate<A: Arbitrary>() -> Function1LazyCompositionOf<I, A> {
        Function1LazyComposition.arbitrary.generate
    }
}
