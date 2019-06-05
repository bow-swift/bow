import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Try: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<Try<A>> {
        let failure = Gen.pure(Try<A>.failure(TryError.illegalState))
        let success = A.arbitrary.map(Try.success)
        return Gen.one(of: [failure, success])
    }
}
