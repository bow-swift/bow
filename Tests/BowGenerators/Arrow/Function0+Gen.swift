import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Function0: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<Function0<A>> {
        A.arbitrary.map { a in Function0 { a } }
    }
}

// MARK: Instance of `ArbitraryK` for `Function0`

extension Function0Partial: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Function0Of<A> {
        Function0.arbitrary.generate
    }
}
