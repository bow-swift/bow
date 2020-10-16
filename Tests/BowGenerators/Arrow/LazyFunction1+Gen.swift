import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension LazyFunction1: Arbitrary where I: CoArbitrary & Hashable, O: Arbitrary {
    public static var arbitrary: Gen<LazyFunction1<I, O>> {
        ArrowOf<I, O>.arbitrary.map { arrow in
            LazyFunction1(arrow.getArrow)
        }
    }
}

// MARK: Instance of ArbitraryK for LazyFunction1

extension LazyFunction1Partial: ArbitraryK where I: CoArbitrary & Hashable {
    public static func generate<A: Arbitrary>() -> LazyFunction1Of<I, A> {
        LazyFunction1.arbitrary.generate
    }
}
