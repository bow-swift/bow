import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Function1: Arbitrary where I: CoArbitrary & Hashable, O: Arbitrary {
    public static var arbitrary: Gen<Function1<I, O>> {
        return ArrowOf<I, O>.arbitrary.map { arrow in Function1(arrow.getArrow) }
    }
}
