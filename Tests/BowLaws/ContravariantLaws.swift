import SwiftCheck
import Bow
import BowGenerators

public class ContravariantLaws<F: Contravariant & EquatableK & ArbitraryK> {
    
    public static func check() {
        InvariantLaws<F>.check()
        identity()
        composition()
    }
    
    private static func identity() {
        property("Identity") <~ forAll { (fa: KindOf<F, Int>) in
            return F.contramap(fa.value, id) == id(fa.value)
        }
    }
    
    private static func composition() {
        property("Composition") <~ forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>, g: ArrowOf<Int, Int>) in
            return F.contramap(F.contramap(fa.value, f.getArrow), g.getArrow) ==
                F.contramap(fa.value, f.getArrow <<< g.getArrow)
        }
    }
}
