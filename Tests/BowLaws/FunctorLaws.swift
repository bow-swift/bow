import SwiftCheck
import Bow
import BowGenerators

public class FunctorLaws<F: Functor & EquatableK & ArbitraryK> {
    public static func check() {
        InvariantLaws<F>.check()
        covariantIdentity()
        covariantComposition()
        void()
        fproduct()
        tupleLeft()
        tupleRight()
    }

    private static func covariantIdentity() {
        property("Identity is preserved under functor transformation") <~ forAll() { (fa: KindOf<F, Int>) in
            return F.map(fa.value, id) == id(fa.value)
        }
    }
    
    private static func covariantComposition() {
        property("Composition is preserved under functor transformation") <~ forAll() { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>, g: ArrowOf<Int, Int>) in
            return F.map(F.map(fa.value, f.getArrow), g.getArrow) ==
                F.map(fa.value, f.getArrow >>> g.getArrow)
        }
    }
    
    private static func void() {
        property("Void") <~ forAll() { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            return isEqual(F.void(fa.value), F.void(F.map(fa.value, f.getArrow)))
        }
    }
    
    private static func fproduct() {
        property("fproduct") <~ forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            return F.map(F.fproduct(fa.value, f.getArrow), { x in x.1 }) ==
                F.map(fa.value, f.getArrow)
        }
    }
    
    private static func tupleLeft() {
        property("tuple left") <~ forAll { (fa: KindOf<F, Int>, b: Int) in
            return F.map(F.tupleLeft(fa.value, b), { x in x.0 }) ==
                F.as(fa.value, b)
        }
    }
    
    private static func tupleRight() {
        property("tuple right") <~ forAll { (fa: KindOf<F, Int>, b: Int) in
            return F.map(F.tupleRight(fa.value, b), { x in x.1 }) ==
                F.as(fa.value, b)
        }
    }
}
