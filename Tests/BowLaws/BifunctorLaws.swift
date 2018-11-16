import Foundation
import SwiftCheck
@testable import Bow

class BifunctorLaws<F> {
    static func check<Bif, EqInt>(bifunctor : Bif, generator : @escaping (Int) -> Kind2<F, Int, Int>, eq : EqInt)
        where Bif : Bifunctor, Bif.F == F, EqInt : Eq, EqInt.A == Kind2<F, Int, Int> {
            identity(bifunctor, generator, eq)
            composition(bifunctor, generator, eq)
    }
    
    private static func identity<Bif, EqInt>(_ bifunctor : Bif, _ generator : @escaping (Int) -> Kind2<F, Int, Int>, _ eq : EqInt)
        where Bif : Bifunctor, Bif.F == F, EqInt : Eq, EqInt.A == Kind2<F, Int, Int> {
            property("Identity") <- forAll { (a : Int) in
                let fa = generator(a)
                return eq.eqv(bifunctor.bimap(fa, id, id), id(fa))
            }
    }
    
    private static func composition<Bif, EqInt>(_ bifunctor : Bif, _ generator : @escaping (Int) -> Kind2<F, Int, Int>, _ eq : EqInt)
        where Bif : Bifunctor, Bif.F == F, EqInt : Eq, EqInt.A == Kind2<F, Int, Int> {
            property("Composition") <- forAll { (a : Int, f1 : ArrowOf<Int, Int>, f2 : ArrowOf<Int, Int>, g1 : ArrowOf<Int, Int>, g2 : ArrowOf<Int, Int>) in
                let fa = generator(a)
                return eq.eqv(bifunctor.bimap(bifunctor.bimap(fa, f1.getArrow, f2.getArrow), g1.getArrow, g2.getArrow),
                              bifunctor.bimap(fa, g1.getArrow <<< f1.getArrow, g2.getArrow <<< f1.getArrow))
            }
    }
}
