import Bow
import BowGenerators
import BowRx
import SwiftCheck

// MARK: Generator for Property-based Testing

extension SingleK: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<SingleK<A>> {
        return A.arbitrary.map { x in SingleK.pure(x)^ }
    }
}

// MARK: Instance of `ArbitraryK` for `SingleK`

extension ForSingleK: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<ForSingleK, A> {
        return SingleK.arbitrary.generate
    }
}
