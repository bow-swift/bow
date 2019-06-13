import SwiftCheck
import Bow
import BowGenerators

class AlternativeLaws<F: Alternative & EquatableK & ArbitraryK> {
    public static func check()  {
        rightAbsorption()
        leftDistributivity()
        rightDistributivity()
    }
    
    private static func rightAbsorption() {
        property("Right absorption") <- forAll { (ff: KindOf<F, ArrowOf<Int, Int>>) in
            return F.ap(F.emptyK(), ff.value) ==
                F.emptyK() as Kind<F, Int>
        }
    }
    
    private static func leftDistributivity() {
        property("Left distributivity") <- forAll { (fx: KindOf<F, Int>, fy: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            return F.map(F.combineK(fx.value, fy.value), f.getArrow) ==
                F.combineK(F.map(fx.value, f.getArrow), F.map(fy.value, f.getArrow))
        }
    }
    
    private static func rightDistributivity() {
        property("Left distributivity") <- forAll { (fx: KindOf<F, Int>, f: ArrowOf<Int, Int>, g: ArrowOf<Int, Int>) in
            return F.ap(F.combineK(F.pure(f.getArrow), F.pure(g.getArrow)),
                        fx.value) ==
                F.combineK(F.ap(F.pure(f.getArrow), fx.value),
                           F.ap(F.pure(g.getArrow), fx.value))
        }
    }
}
