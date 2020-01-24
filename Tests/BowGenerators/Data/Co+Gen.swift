import Bow
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `Co`
extension CoTPartial: ArbitraryK where W: ArbitraryK, M: ArbitraryK {
    public static func generate<A: Arbitrary>() -> CoTOf<W, M, A> {
        let wa: Kind<W, A> = W.generate()
        return CoT.pure(wa.extract())
    }
}
