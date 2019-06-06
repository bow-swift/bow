import Bow
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `WriterT`

extension WriterTPartial: ArbitraryK where F: ArbitraryK & Applicative, W: Arbitrary {
    public static func generate<A: Arbitrary>() -> Kind<WriterTPartial<F, W>, A> {
        return WriterT(F.pure((W.arbitrary.generate, A.arbitrary.generate)))
    }
}
