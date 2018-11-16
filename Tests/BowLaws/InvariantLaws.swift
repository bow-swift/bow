import Foundation
import SwiftCheck
@testable import Bow

class InvariantLaws<F> {
    static func check<Inv, EqInt>(invariant : Inv, generator : @escaping (Int) -> Kind<F, Int>, eq : EqInt)
        where EqInt : Eq, EqInt.A == Kind<F, Int>, Inv : Invariant, Inv.F == F {
        self.identity(invariant, generator, eq)
        self.composition(invariant, generator, eq)
    }
    
    private static func identity<Inv, EqInt>(_ invariant : Inv, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqInt)
        where EqInt : Eq, EqInt.A == Kind<F, Int>, Inv : Invariant, Inv.F == F {
            property("Identity") <- forAll { (a : Int) in
                let fa = generator(a)
                return eq.eqv(invariant.imap(fa, id, id), fa)
            }
    }
    
    private static func composition<Inv, EqInt>(_ invariant : Inv, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqInt)
        where EqInt : Eq, EqInt.A == Kind<F, Int>, Inv : Invariant, Inv.F == F {
            property("Composition") <- forAll { (a : Int, f1 : ArrowOf<Int, Int>, f2 : ArrowOf<Int, Int>, g1 : ArrowOf<Int, Int>, g2 : ArrowOf<Int, Int>) in
                let fa = generator(a)
                return eq.eqv(invariant.imap(invariant.imap(fa, f1.getArrow, f2.getArrow), g1.getArrow, g2.getArrow),
                              invariant.imap(fa, g1.getArrow <<< f1.getArrow, f2.getArrow <<< g2.getArrow))
            }
    }
}
