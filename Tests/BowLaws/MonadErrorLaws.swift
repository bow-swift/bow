import SwiftCheck
import Bow
import BowGenerators

public class MonadErrorLaws<F: MonadError & EquatableK & ArbitraryK> where F.E: Arbitrary {
    public static func check()  {
        leftZero()
        ensureConsistency()
    }
    
    private static func leftZero() {
        property("Left zero") <~ forAll { (a: Int, g: ArrowOf<Int, Int>, error: F.E) in
            let f = g.getArrow >>> F.pure
            
            return F.raiseError(error).flatMap(f)
                ==
            F.raiseError(error)
        }
    }
    
    private static func ensureConsistency() {
        property("Ensure consistency") <~ forAll { (fa: KindOf<F, Int>, p: ArrowOf<Int, Bool>, error: F.E) in
            
            fa.value.ensure(constant(error), p.getArrow)
                ==
            fa.value.flatMap { a in
                p.getArrow(a) ? F.pure(a) : F.raiseError(error)
            }
        }
    }
}
