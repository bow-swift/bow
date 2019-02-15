import Foundation
import SwiftCheck
@testable import Bow

class ContravariantLaws<F: Contravariant & EquatableK> {
    
    static func check(generator: @escaping (Int) -> Kind<F, Int>) {
        InvariantLaws.check(generator: generator)
        identity(generator)
        composition(generator)
    }
    
    private static func identity(_ generator: @escaping (Int) -> Kind<F, Int>) {
            property("Identity") <- forAll { (a: Int) in
                let fa = generator(a)
                return F.contramap(fa, id) == id(fa)
            }
    }
    
    private static func composition(_ generator: @escaping (Int) -> Kind<F, Int>) {
            property("Composition") <- forAll { (a: Int, f: ArrowOf<Int, Int>, g: ArrowOf<Int, Int>) in
                let fa = generator(a)
                return F.contramap(F.contramap(fa, f.getArrow), g.getArrow) == F.contramap(fa, f.getArrow <<< g.getArrow)
            }
    }
}
