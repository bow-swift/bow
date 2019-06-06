import Bow
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `Moore`

extension MoorePartial: ArbitraryK where E: CoArbitrary & Hashable {
    public static func generate<A: Arbitrary>() -> Kind<MoorePartial<E>, A> {
        func handle(_ x: E) -> Moore<E, A> {
            return Moore(view: A.arbitrary.generate, handle: handle)
        }
        
        return Moore(view: A.arbitrary.generate, handle: handle)
    }
}
