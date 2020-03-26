import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension EitherK: Arbitrary where F: ArbitraryK, G: ArbitraryK, A: Arbitrary {
    public static var arbitrary: Gen<EitherK<F, G, A>> {
        Gen.from(EitherKPartial.generate >>> EitherK.fix)
    }
}

// MARK: Instance of `ArbitraryK` for `EitherK`

extension EitherKPartial: ArbitraryK where F: ArbitraryK, G: ArbitraryK {
    public static func generate<A: Arbitrary>() -> EitherKOf<F, G, A> {
        let left = EitherK<F, G, A>(F.generate())
        let right = EitherK<F, G, A>(G.generate())
        return Gen.one(of: [Gen.pure(left), Gen.pure(right)]).generate
    }
}
