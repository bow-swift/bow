import Bow
import BowEffects
import BowGenerators
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `IO`

extension IOPartial: ArbitraryK where E: Arbitrary {
    public static func generate<A: Arbitrary>() -> Kind<IOPartial<E>, A> {
        let success = IO<E, A>.pure(A.arbitrary.generate)
        let failure = IO<E, A>.raiseError(E.arbitrary.generate)
        let gen = Gen.one(of: [Gen.pure(success), Gen.pure(failure)])
        return gen.generate
    }
}
