import Bow
import SwiftCheck

// MARK: Generator for Propery-based Testing

extension WriterT: Arbitrary where F: ArbitraryK & Applicative, W: Arbitrary, A: Arbitrary {
    public static var arbitrary: Gen<WriterT<F, W, A>> {
        Gen.from(WriterTPartial.generate >>> WriterT.fix)
    }
}

// MARK: Instance of ArbitraryK for WriterT

extension WriterTPartial: ArbitraryK where F: ArbitraryK & Applicative, W: Arbitrary {
    public static func generate<A: Arbitrary>() -> WriterTOf<F, W, A> {
        WriterT(F.pure((W.arbitrary.generate, A.arbitrary.generate)))
    }
}
