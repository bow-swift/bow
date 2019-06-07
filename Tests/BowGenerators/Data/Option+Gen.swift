import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Option: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<Option<A>> {
        let none = Gen.pure(Option<A>.none())
        let some = A.arbitrary.map(Option.some)
        return Gen.one(of: [none, some])
    }
}

// MARK: Instance of `ArbitraryK` for `Option`

extension ForOption: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<ForOption, A> {
        return Option.arbitrary.generate
    }
}
