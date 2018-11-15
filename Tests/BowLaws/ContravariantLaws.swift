import Foundation
import SwiftCheck
@testable import Bow

class ContravariantLaws<F> {
    
    static func check<Contr, EqInt>(contravariant : Contr, generator : @escaping (Int) -> Kind<F, Int>, eq : EqInt)
        where Contr : Contravariant, Contr.F == F, EqInt : Eq, EqInt.A == Kind<F, Int> {
            InvariantLaws.check(invariant: contravariant, generator: generator, eq: eq)
            identity(contravariant, generator, eq)
            composition(contravariant, generator, eq)
    }
    
    private static func identity<Contr, EqInt>(_ contravariant : Contr, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqInt)
        where Contr : Contravariant, Contr.F == F, EqInt : Eq, EqInt.A == Kind<F, Int> {
            property("Identity") <- forAll { (a : Int) in
                let fa = generator(a)
                return eq.eqv(contravariant.contramap(fa, id), id(fa))
            }
    }
    
    private static func composition<Contr, EqInt>(_ contravariant : Contr, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqInt)
        where Contr : Contravariant, Contr.F == F, EqInt : Eq, EqInt.A == Kind<F, Int> {
            property("Composition") <- forAll { (a : Int, f : ArrowOf<Int, Int>, g : ArrowOf<Int, Int>) in
                let fa = generator(a)
                return eq.eqv(contravariant.contramap(contravariant.contramap(fa, f.getArrow), g.getArrow),
                              contravariant.contramap(fa, f.getArrow <<< g.getArrow))
            }
    }
}
