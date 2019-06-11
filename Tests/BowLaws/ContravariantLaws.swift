import Foundation
import SwiftCheck
import Bow
import BowGenerators

class ContravariantLaws<F: Contravariant & EquatableK & ArbitraryK> {
    
    static func check(generator: @escaping (Int) -> Kind<F, Int>) {
        InvariantLaws.check(generator: generator)
        identity()
        composition()
    }
    
    private static func identity() {
        property("Identity") <- forAll { (fa: KindOf<F, Int>) in
            return F.contramap(fa.value, id) == id(fa.value)
        }
    }
    
    private static func composition() {
        property("Composition") <- forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>, g: ArrowOf<Int, Int>) in
            return F.contramap(F.contramap(fa.value, f.getArrow), g.getArrow) ==
                F.contramap(fa.value, f.getArrow <<< g.getArrow)
        }
    }
}
