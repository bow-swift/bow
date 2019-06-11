import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Function0: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<Function0<A>> {
        return A.arbitrary.map { a in Function0 { a } }
    }
}

// MARK: Instance of `ArbitraryK` for `Function0`

extension ForFunction0: ArbitraryK {
    public static func generate<A>() -> Kind<ForFunction0, A> where A : Arbitrary {
        return Function0.arbitrary.generate
    }
}
