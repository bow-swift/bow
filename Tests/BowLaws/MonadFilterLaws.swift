import SwiftCheck
import Bow
import BowGenerators

class MonadFilterLaws<F: MonadFilter & EquatableK & ArbitraryK> {
    static func check() {
        leftEmpty()
        rightEmpty()
        consistency()
        mapFilter()
        filter()
    }
    
    private static func leftEmpty() {
        property("Left empty") <- forAll { (f: ArrowOf<Int, Int>) in
            return F.flatMap(F.empty(), f.getArrow >>> F.pure) == F.empty()
        }
    }
    
    private static func rightEmpty() {
        property("Right empty") <- forAll { (fa: KindOf<F, Int>) in
            return F.flatMap(fa.value, constant(F.empty())) == F.empty() as Kind<F, Int>
        }
    }
    
    private static func consistency()  {
        property("Consistency") <- forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, Bool>) in
            return F.filter(fa.value, f.getArrow) == F.flatMap(fa.value, { a in f.getArrow(a) ? F.pure(a) : F.empty() })
        }
    }
    
    private static func mapFilter() {
        property("mapFilter") <- forAll { (flag: Bool, n: Int) in
            return F.pure(()).mapFilter { _ in flag ? Option.some(n) : Option.none() } ==
                (flag ? F.pure(n) : F.empty())
        }
    }
    
    private static func filter() {
        property("filter") <- forAll { (flag: Bool, n: Int) in
            return F.pure(n).filter(constant(flag)) == (flag ? F.pure(n) : F.empty())
        }
    }
}
