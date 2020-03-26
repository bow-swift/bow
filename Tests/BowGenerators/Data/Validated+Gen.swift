import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Validated: Arbitrary where E: Arbitrary, A: Arbitrary {
    public static var arbitrary: Gen<Validated<E, A>> {
        let invalid = E.arbitrary.map(Validated.invalid)
        let valid = A.arbitrary.map(Validated.valid)
        return Gen.one(of: [invalid, valid])
    }
}

// MARK: Instance of ArbitraryK for Validated

extension ValidatedPartial: ArbitraryK where I: Arbitrary {
    public static func generate<A: Arbitrary>() -> ValidatedOf<I, A> {
        Validated.arbitrary.generate
    }
}
