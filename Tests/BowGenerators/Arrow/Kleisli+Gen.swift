import Bow
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `Kleisli`

extension KleisliPartial: ArbitraryK where F: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<KleisliPartial<F, D>, A> {
        return Kleisli { _ in F.generate() }
    }
}
