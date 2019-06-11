import Bow
import BowGenerators
import BowRx
import SwiftCheck

// MARK: Generator for Property-based Testing

extension MaybeK: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<MaybeK<A>> {
        return A.arbitrary.map { x in MaybeK.pure(x)^ }
    }
}

// MARK: Instance of `ArbitraryK` for `MaybeK`

extension ForMaybeK: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<ForMaybeK, A> {
        return MaybeK.arbitrary.generate
    }
}
