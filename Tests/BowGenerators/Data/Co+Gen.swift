import Bow
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `Co`
extension CoPartial: ArbitraryK where W: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<CoPartial<W>, A> {
        let wa: Kind<W, A> = W.generate()
        return Co.pure(wa.extract())
    }
}
