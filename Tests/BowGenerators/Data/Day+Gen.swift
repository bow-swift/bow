import Bow
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `Day`

extension DayPartial: ArbitraryK where F: ArbitraryK, G: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<DayPartial<F, G>, A> {
        let left: Kind<F, A> = F.generate()
        let right: Kind<G, A> = G.generate()
        let f = (Int.arbitrary.generate % 2 == 0) ? { (x: A, _: A) in x } : { (_: A, x: A) in x }
        return Day.from(left: left, right: right, f: f)
    }
}
