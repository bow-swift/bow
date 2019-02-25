import Foundation
import SwiftCheck
@testable import Bow

class MonadErrorLaws<F: MonadError & EquatableK> where F.E: Arbitrary {
    
    static func check()  {
        leftZero()
        ensureConsistency()
    }
    
    private static func leftZero() {
        property("Left zero") <- forAll { (a: Int, g: ArrowOf<Int, Int>, error: F.E) in
            let f = g.getArrow >>> F.pure
            return F.flatMap(F.raiseError(error), f) == F.raiseError(error)
        }
    }
    
    private static func ensureConsistency() {
        property("Ensure consistency") <- forAll { (a: Int, p: ArrowOf<Int, Bool>, error: F.E) in
            let fa = F.pure(a)
            return F.ensure(fa, constant(error), p.getArrow) == F.flatMap(fa, { a in p.getArrow(a) ? F.pure(a) : F.raiseError(error) })
        }
    }
    
}
