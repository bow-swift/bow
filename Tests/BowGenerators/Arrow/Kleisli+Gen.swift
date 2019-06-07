import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Kleisli: Arbitrary where F: ArbitraryK, A: Arbitrary {
    public static var arbitrary: Gen<Kleisli<F, D, A>> {
        let kleisli: Kleisli<F, D, A> = KleisliPartial.generate()^
        return Gen.pure(kleisli)
    }
}

// MARK: Instance of `ArbitraryK` for `Kleisli`

extension KleisliPartial: ArbitraryK where F: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<KleisliPartial<F, D>, A> {
        return Kleisli { _ in F.generate() }
    }
}
