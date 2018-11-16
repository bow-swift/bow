import SwiftCheck
@testable import Bow

class AlternativeLaws<F> {
    
    public static func check<Alt, EqA>(alternative : Alt, eq : EqA) where Alt : Alternative, Alt.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        rightAbsorption(alternative, eq)
        leftDistributivity(alternative, eq)
        rightDistributivity(alternative, eq)
    }
    
    private static func rightAbsorption<Alt, EqA>(_ alternative : Alt, _ eq : EqA) where Alt : Alternative, Alt.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("Right absorption") <- forAll { (f : ArrowOf<Int, Int>) in
            return eq.eqv(alternative.ap(alternative.emptyK(), alternative.pure(f.getArrow)),
                          alternative.emptyK())
        }
    }
    
    private static func leftDistributivity<Alt, EqA>(_ alternative : Alt, _ eq : EqA) where Alt : Alternative, Alt.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("Left distributivity") <- forAll { (x : Int, y : Int, f : ArrowOf<Int, Int>) in
            return eq.eqv(alternative.map(alternative.combineK(alternative.pure(x),
                                                               alternative.pure(y)), f.getArrow),
                          alternative.combineK(alternative.map(alternative.pure(x), f.getArrow),
                                               alternative.map(alternative.pure(y), f.getArrow)))
        }
    }
    
    private static func rightDistributivity<Alt, EqA>(_ alternative : Alt, _ eq : EqA) where Alt : Alternative, Alt.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("Left distributivity") <- forAll { (x : Int, f : ArrowOf<Int, Int>, g : ArrowOf<Int, Int>) in
            return eq.eqv(alternative.ap(alternative.pure(x),
                                         alternative.combineK(alternative.pure(f.getArrow),
                                                              alternative.pure(g.getArrow))),
                          alternative.combineK(alternative.ap(alternative.pure(x),
                                                              alternative.pure(f.getArrow)),
                                               alternative.ap(alternative.pure(x),
                                                              alternative.pure(g.getArrow))))
        }
    }
}
