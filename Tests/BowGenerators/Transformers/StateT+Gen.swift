import Bow
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `StateT`

extension StateTPartial: ArbitraryK where F: ArbitraryK & Applicative, S: Arbitrary {
    public static func generate<A: Arbitrary>() -> Kind<StateTPartial<F, S>, A> {
        let f: (S) -> Kind<F, (S, A)> = { s in F.pure((s, A.arbitrary.generate)) }
        return StateT(F.pure(f))
    }
}
