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
            fa.value.map(id)
                ==
            id(fa.value)
        }
    }
    
    private static func covariantComposition() {
        property("Composition is preserved under functor transformation") <~ forAll() { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>, g: ArrowOf<Int, Int>) in
            
            fa.value.map(f.getArrow).map(g.getArrow)
                ==
            fa.value.map(f.getArrow >>> g.getArrow)
        }
    }
    
    private static func void() {
        property("Void") <~ forAll() { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            
            isEqual(
                fa.value.void(),
                fa.value.map(f.getArrow).void())
        }
    }
    
    private static func fproduct() {
        property("fproduct") <~ forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            
            fa.value.fproduct(f.getArrow).map { x in x.1 }
                ==
            fa.value.map(f.getArrow)
        }
    }
    
    private static func tupleLeft() {
        property("tuple left") <~ forAll { (fa: KindOf<F, Int>, b: Int) in
            
            fa.value.tupleLeft(b).map { x in x.0 }
                ==
            fa.value.as(b)
        }
    }
    
    private static func tupleRight() {
        property("tuple right") <~ forAll { (fa: KindOf<F, Int>, b: Int) in
            
            fa.value.tupleRight(b).map { x in x.1 }
                ==
            fa.value.as(b)
        }
    }
}
