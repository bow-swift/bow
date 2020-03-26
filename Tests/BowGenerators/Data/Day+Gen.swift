import Bow
import SwiftCheck

// MARK: Instance of ArbitraryK for Day

extension DayPartial: ArbitraryK where F: ArbitraryK, G: ArbitraryK {
    public static func generate<A: Arbitrary>() -> DayOf<F, G, A> {
        let left = F.generate().map { (a: A) in a as Any}
        let right = G.generate().map { (a: A) in a as Any }
        let f = (Int.arbitrary.generate % 2 == 0) ? { (x: Any, _: Any) in x as! A } : { (_: Any, x: Any) in x as! A }
        return Day(left: left, right: right, f)
    }
}
