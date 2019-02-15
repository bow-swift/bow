import SwiftCheck
@testable import Bow

class AlternativeLaws<F: Alternative & EquatableK> {
    
    public static func check()  {
        rightAbsorption()
        leftDistributivity()
        rightDistributivity()
    }
    
    private static func rightAbsorption() {
        property("Right absorption") <- forAll { (f: ArrowOf<Int, Int>) in
            return F.ap(F.emptyK(), F.pure(f.getArrow)) ==
                F.emptyK() as Kind<F, Int>
        }
    }
    
    private static func leftDistributivity() {
        property("Left distributivity") <- forAll { (x: Int, y: Int, f: ArrowOf<Int, Int>) in
            return F.map(F.combineK(F.pure(x), F.pure(y)), f.getArrow) ==
                F.combineK(F.map(F.pure(x), f.getArrow), F.map(F.pure(y), f.getArrow))
        }
    }
    
    private static func rightDistributivity() {
        property("Left distributivity") <- forAll { (x: Int, f: ArrowOf<Int, Int>, g: ArrowOf<Int, Int>) in
            return F.ap(F.combineK(F.pure(f.getArrow), F.pure(g.getArrow)),
                        F.pure(x)) ==
                F.combineK(F.ap(F.pure(f.getArrow), F.pure(x)),
                           F.ap(F.pure(g.getArrow), F.pure(x)))
        }
    }
}
