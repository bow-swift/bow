import Bow
import BowFree
import BowGenerators
import SwiftCheck

// MARK: Instance of ArbitraryK for Cofree

extension CofreePartial: ArbitraryK where F: ArbitraryK {
    public static func generate<A: Arbitrary>() -> CofreeOf<F, A> {
        Cofree.arbitrary.generate
    }
}

// MARK: Instance of Arbitrary for Cofree

extension Cofree: Arbitrary where F: ArbitraryK, A: Arbitrary {
    public static var arbitrary: Gen<Cofree<F, A>> {
        Gen.zip(
            A.arbitrary,
            Gen.from(F.generate).map { fa in Eval.later { fa } }
        ).map(Cofree.init)
    }
}
