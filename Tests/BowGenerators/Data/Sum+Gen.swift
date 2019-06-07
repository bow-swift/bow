import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Sum: Arbitrary where F: ArbitraryK, G: ArbitraryK, V: Arbitrary {
    public static var arbitrary: Gen<Sum<F, G, V>> {
        let fa: Kind<F, V> = F.generate()
        let ga: Kind<G, V> = G.generate()
        let left = Sum.left(fa, ga)
        let right = Sum.right(fa, ga)
        
        return Gen.one(of: [Gen.pure(left), Gen.pure(right)])
    }
}

// MARK: Instance of `ArbitraryK` for `Sum`

extension SumPartial: ArbitraryK where F: ArbitraryK, G: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<SumPartial<F, G>, A> {
        return Sum.arbitrary.generate
    }
}
