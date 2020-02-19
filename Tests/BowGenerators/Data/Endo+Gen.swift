import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Endo: Arbitrary where A: CoArbitrary & Hashable & Arbitrary {
    public static var arbitrary: Gen<Endo<A>> {
        ArrowOf<A, A>.arbitrary.map { arrow in Endo(arrow.getArrow) }
    }
}
