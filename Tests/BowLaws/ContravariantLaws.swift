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
            
            fa.value.contramap(id)
                ==
            id(fa.value)
        }
    }
    
    private static func composition() {
        property("Composition") <~ forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>, g: ArrowOf<Int, Int>) in
            
            fa.value.contramap(f.getArrow).contramap(g.getArrow)
                ==
            fa.value.contramap(f.getArrow <<< g.getArrow)
        }
    }
}
