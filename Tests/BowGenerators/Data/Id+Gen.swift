import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Id: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<Id<A>> {
        return A.arbitrary.map(Id.init)
    }
}

// MARK: Instance of `ArbitraryK` for `Id`

extension ForId: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<ForId, A> {
        return Id.arbitrary.generate
    }
}
