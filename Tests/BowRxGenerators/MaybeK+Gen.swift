import Bow
import BowGenerators
import BowRx
import SwiftCheck

// MARK: Generator for Property-based Testing

extension MaybeK: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<MaybeK<A>> {
        A.arbitrary.map { x in MaybeK.pure(x)^ }
    }
}

// MARK: Instance of `ArbitraryK` for `MaybeK`

extension MaybeKPartial: ArbitraryK {
    public static func generate<A: Arbitrary>() -> MaybeKOf<A> {
        MaybeK.arbitrary.generate
    }
}
