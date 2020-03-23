import Bow
import BowGenerators
import BowRx
import SwiftCheck

// MARK: Generator for Property-based Testing

extension SingleK: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<SingleK<A>> {
        A.arbitrary.map { x in SingleK.pure(x)^ }
    }
}

// MARK: Instance of `ArbitraryK` for `SingleK`

extension SingleKPartial: ArbitraryK {
    public static func generate<A: Arbitrary>() -> SingleKOf<A> {
        SingleK.arbitrary.generate
    }
}
