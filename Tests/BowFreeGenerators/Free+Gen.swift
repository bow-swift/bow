import Bow
import BowFree
import BowGenerators
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `Free`

extension FreePartial: ArbitraryK where F: ArbitraryK {
    public static func generate<A: Arbitrary>() -> FreeOf<F, A> {
        Free<F, A>.arbitrary.generate
    }
}

extension Free: Arbitrary where F: ArbitraryK, A: Arbitrary {
    public static var arbitrary: Gen<Free<F, A>> {
        let pureGen: Gen<Free<F, A>> = A.arbitrary.map(Free<F, A>.pure >>> Free.fix)
        let liftGen: Gen<Free<F, A>> = Gen.from(F.generate).map(Free<F, A>.free)
        
        return Gen.one(of: [pureGen, liftGen])
    }
}
