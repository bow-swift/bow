import SwiftCheck
import Bow
import BowGenerators

public class InvariantLaws<F: Invariant & EquatableK & ArbitraryK> {
    public static func check() {
        self.identity()
        self.composition()
    }
    
    private static func identity() {
        property("Identity") <- forAll { (fa: KindOf<F, Int>) in
            return F.imap(fa.value, id, id) == fa.value
        }
    }
    
    private static func composition() {
        property("Composition") <- forAll { (fa: KindOf<F, Int>, f1: ArrowOf<Int, Int>, f2: ArrowOf<Int, Int>, g1: ArrowOf<Int, Int>, g2: ArrowOf<Int, Int>) in
            let left = F.imap(F.imap(fa.value, f1.getArrow, f2.getArrow), g1.getArrow, g2.getArrow)
            let right = F.imap(fa.value, g1.getArrow <<< f1.getArrow, f2.getArrow <<< g2.getArrow)
            return left == right
        }
    }
}
