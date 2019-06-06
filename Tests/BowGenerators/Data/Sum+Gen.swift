import Bow
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `Sum`

extension SumPartial: ArbitraryK where F: ArbitraryK, G: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<SumPartial<F, G>, A> {
        let fa: Kind<F, A> = F.generate()
        let ga: Kind<G, A> = G.generate()
        let left = Sum.left(fa, ga)
        let right = Sum.right(fa, ga)
        return (Int.arbitrary.generate % 2 == 0) ? left : right
    }
}
