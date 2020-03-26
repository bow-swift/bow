import SwiftCheck
import Bow
import BowGenerators

public class MonadFilterLaws<F: MonadFilter & EquatableK & ArbitraryK> {
    public static func check() {
        leftEmpty()
        rightEmpty()
        consistency()
        mapFilter()
        filter()
    }
    
    private static func leftEmpty() {
        property("Left empty") <~ forAll { (f: ArrowOf<Int, Int>) in
            
            Kind<F, Int>.empty.flatMap(f.getArrow >>> F.pure)
                ==
            Kind<F, Int>.empty
        }
    }
    
    private static func rightEmpty() {
        property("Right empty") <~ forAll { (fa: KindOf<F, Int>) in
            
            fa.value.followedBy(Kind<F, Int>.empty)
                ==
            Kind<F, Int>.empty
        }
    }
    
    private static func consistency()  {
        property("Consistency") <~ forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, Bool>) in
            
            fa.value.filter(f.getArrow)
                ==
            fa.value.flatMap { a in
                f.getArrow(a) ? F.pure(a) : F.empty()
            }
        }
    }
    
    private static func mapFilter() {
        property("mapFilter") <~ forAll { (flag: Bool, n: Int) in
            
            F.pure(()).mapFilter { _ in
                flag ? Option.some(n) : Option.none()
            }
                ==
            (flag ? F.pure(n) : F.empty())
        }
    }
    
    private static func filter() {
        property("filter") <~ forAll { (flag: Bool, n: Int) in
            
            F.pure(n).filter(constant(flag))
                ==
            (flag ? F.pure(n) : F.empty())
        }
    }
}
