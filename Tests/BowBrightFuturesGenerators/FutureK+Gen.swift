import Bow
import BowBrightFutures
import BowGenerators
import SwiftCheck

// MARK: Generator for Property-based Testing

extension FutureK: Arbitrary where E: Arbitrary, A: Arbitrary {
    public static var arbitrary: Gen<FutureK<E, A>> {
        let success = A.arbitrary.map { x in FutureK.pure(x)^ }
        let failure = E.arbitrary.map { x in FutureK.raiseError(x)^ }
        return Gen.one(of: [success, failure])
    }
}

// MARK: Instance of `ArbitraryK` for `FutureK`

extension FutureKPartial: ArbitraryK where E: Arbitrary {
    public static func generate<A: Arbitrary>() -> Kind<FutureKPartial<E>, A> {
        return FutureK.arbitrary.generate
    }
}
