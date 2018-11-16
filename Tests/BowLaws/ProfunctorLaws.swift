import Foundation
import SwiftCheck
@testable import Bow

class ProfunctorLaws<F> {
    static func check<Prof, EqInt>(profunctor : Prof, generator : @escaping (Int) -> Kind2<F, Int, Int>, eq : EqInt)
        where Prof : Profunctor, Prof.F == F, EqInt : Eq, EqInt.A == Kind2<F, Int, Int> {
            identity(profunctor, generator, eq)
            composition(profunctor, generator, eq)
            lMapIdentity(profunctor, generator, eq)
            rMapIdentity(profunctor, generator, eq)
            lMapComposition(profunctor, generator, eq)
            rMapComposition(profunctor, generator, eq)
    }
    
    private static func identity<Prof, EqInt>(_ profunctor : Prof, _ generator : @escaping (Int) -> Kind2<F, Int, Int>, _ eq : EqInt)
        where Prof : Profunctor, Prof.F == F, EqInt : Eq, EqInt.A == Kind2<F, Int, Int> {
            property("Identity") <- forAll { (a : Int) in
                let fa = generator(a)
                return eq.eqv(profunctor.dimap(fa, id, id), id(fa))
            }
    }
    
    private static func composition<Prof, EqInt>(_ profunctor : Prof, _ generator : @escaping (Int) -> Kind2<F, Int, Int>, _ eq : EqInt)
        where Prof : Profunctor, Prof.F == F, EqInt : Eq, EqInt.A == Kind2<F, Int, Int> {
            property("Composition") <- forAll { (a : Int, f1 : ArrowOf<Int, Int>, f2 : ArrowOf<Int, Int>, g1 : ArrowOf<Int, Int>, g2 : ArrowOf<Int, Int>) in
                let fa = generator(a)
                return eq.eqv(profunctor.dimap(profunctor.dimap(fa, f1.getArrow, f2.getArrow), g1.getArrow, g2.getArrow),
                              profunctor.dimap(fa, f1.getArrow <<< g1.getArrow, g2.getArrow <<< f2.getArrow))
            }
    }
    
    private static func lMapIdentity<Prof, EqInt>(_ profunctor : Prof, _ generator : @escaping (Int) -> Kind2<F, Int, Int>, _ eq : EqInt)
        where Prof : Profunctor, Prof.F == F, EqInt : Eq, EqInt.A == Kind2<F, Int, Int> {
            property("lmap identity") <- forAll { (a : Int) in
                let fa = generator(a)
                return eq.eqv(profunctor.lmap(fa, id), id(fa))
            }
    }
    
    private static func rMapIdentity<Prof, EqInt>(_ profunctor : Prof, _ generator : @escaping (Int) -> Kind2<F, Int, Int>, _ eq : EqInt)
        where Prof : Profunctor, Prof.F == F, EqInt : Eq, EqInt.A == Kind2<F, Int, Int> {
            property("rmap identity") <- forAll { (a : Int) in
                let fa = generator(a)
                return eq.eqv(profunctor.rmap(fa, id), id(fa))
            }
    }
    
    private static func lMapComposition<Prof, EqInt>(_ profunctor : Prof, _ generator : @escaping (Int) -> Kind2<F, Int, Int>, _ eq : EqInt)
        where Prof : Profunctor, Prof.F == F, EqInt : Eq, EqInt.A == Kind2<F, Int, Int> {
            property("lmap composition") <- forAll { (a : Int, f : ArrowOf<Int, Int>, g : ArrowOf<Int, Int>) in
                let fa = generator(a)
                return eq.eqv(profunctor.lmap(profunctor.lmap(fa, g.getArrow), f.getArrow),
                              profunctor.lmap(fa, g.getArrow <<< f.getArrow))
            }
    }
    
    private static func rMapComposition<Prof, EqInt>(_ profunctor : Prof, _ generator : @escaping (Int) -> Kind2<F, Int, Int>, _ eq : EqInt)
        where Prof : Profunctor, Prof.F == F, EqInt : Eq, EqInt.A == Kind2<F, Int, Int> {
            property("rmap composition") <- forAll { (a : Int, f : ArrowOf<Int, Int>, g : ArrowOf<Int, Int>) in
                let fa = generator(a)
                return eq.eqv(profunctor.rmap(profunctor.rmap(fa, f.getArrow), g.getArrow),
                              profunctor.rmap(fa, g.getArrow <<< f.getArrow))
            }
    }
}
