import Bow
import BowFree
import BowGenerators
import SwiftCheck

// MARK: Instance of Arbitrary for Coyoneda

extension Coyoneda: Arbitrary where F: ArbitraryK & Functor, A: Arbitrary {
    public static var arbitrary: Gen<Coyoneda<F, A>> {
        KindOf<F, A>.arbitrary.map { fa in
            Coyoneda.liftCoyoneda(fa.value)
        }
    }
}

// MARK: Instance of ArbitraryK for Coyoneda

extension CoyonedaPartial: ArbitraryK where F: ArbitraryK & Functor {
    public static func generate<A: Arbitrary>() -> CoyonedaOf<F, A> {
        Coyoneda.arbitrary.generate
    }
}
