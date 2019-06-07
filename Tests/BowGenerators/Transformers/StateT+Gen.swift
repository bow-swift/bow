import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension StateT: Arbitrary where F: ArbitraryK & Applicative, S: Arbitrary, A: Arbitrary {
    public static var arbitrary: Gen<StateT<F, S, A>> {
        return Gen.from(StateTPartial.generate >>> StateT.fix)
    }
}

// MARK: Instance of `ArbitraryK` for `StateT`

extension StateTPartial: ArbitraryK where F: ArbitraryK & Applicative, S: Arbitrary {
    public static func generate<A: Arbitrary>() -> Kind<StateTPartial<F, S>, A> {
        let f: (S) -> Kind<F, (S, A)> = { s in F.pure((s, A.arbitrary.generate)) }
        return StateT(F.pure(f))
    }
}
