import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Kleisli: Arbitrary where F: ArbitraryK, A: Arbitrary {
    public static var arbitrary: Gen<Kleisli<F, D, A>> {
        return Gen.from(KleisliPartial.generate >>> Kleisli.fix)
    }
}

// MARK: Instance of `ArbitraryK` for `Kleisli`

extension KleisliPartial: ArbitraryK where F: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<KleisliPartial<F, D>, A> {
        return Kleisli { _ in F.generate() }
    }
}
