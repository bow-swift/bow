import Bow
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `EitherK`

extension EitherKPartial: ArbitraryK where F: ArbitraryK, G: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<EitherKPartial<F, G>, A> {
        let left = EitherK<F, G, A>(F.generate())
        let right = EitherK<F, G, A>(G.generate())
        return Gen.one(of: [Gen.pure(left), Gen.pure(right)]).generate
    }
}
