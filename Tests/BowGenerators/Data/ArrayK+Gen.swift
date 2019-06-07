import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension ArrayK: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<ArrayK<A>> {
        return Array.arbitrary.map(ArrayK.init)
    }
}

// MARK: Instance of `ArbitraryK` for `ArrayK`

extension ForArrayK: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<ForArrayK, A> {
        return ArrayK.arbitrary.generate
    }
}
