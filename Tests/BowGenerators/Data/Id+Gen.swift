import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Id: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<Id<A>> {
        A.arbitrary.map(Id.init)
    }
}

// MARK: Instance of `ArbitraryK` for `Id`

extension IdPartial: ArbitraryK {
    public static func generate<A: Arbitrary>() -> IdOf<A> {
        Id.arbitrary.generate
    }
}
