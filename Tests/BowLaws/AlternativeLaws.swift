import SwiftCheck
import Bow
import BowGenerators

public class AlternativeLaws<F: Alternative & EquatableK & ArbitraryK> {
    public static func check()  {
        rightAbsorption()
        leftDistributivity()
        rightDistributivity()
    }
    
    private static func rightAbsorption() {
        property("Right absorption") <~ forAll { (ff: KindOf<F, ArrowOf<Int, Int>>) in
            
            F.emptyK().ap(ff.value)
                ==
            Kind<F, Int>.emptyK()
        }
    }
    
    private static func leftDistributivity() {
        property("Left distributivity") <~ forAll { (fx: KindOf<F, Int>, fy: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            
            fx.value.combineK(fy.value).map(f.getArrow)
                ==
            fx.value.map(f.getArrow).combineK( fy.value.map(f.getArrow))
        }
    }
    
    private static func rightDistributivity() {
        property("Right distributivity") <~ forAll { (fx: KindOf<F, Int>, f: ArrowOf<Int, Int>, g: ArrowOf<Int, Int>) in
            
            F.pure(f.getArrow).combineK(F.pure(g.getArrow))
                .ap(fx.value)
                ==
            F.pure(f.getArrow).ap(fx.value)
                .combineK(F.pure(g.getArrow).ap(fx.value))
        }
    }
}
