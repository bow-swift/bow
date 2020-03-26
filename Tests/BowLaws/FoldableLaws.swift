import SwiftCheck
import Bow
import BowGenerators

public class FoldableLaws<F: Foldable & EquatableK & ArbitraryK> {
    public static func check() {
        leftFoldConsistentWithFoldMap()
        rightFoldConsistentWithFoldMap()
        existsConsistentWithFind()
        existsIsLazy()
        forAllIsLazy()
        forallConsistentWithExists()
        forallReturnsTrueIfEmpty()
        foldMIdIsFoldL()
    }
    
    private static func leftFoldConsistentWithFoldMap() {
        property("Left fold consistent with foldMap") <~ forAll { (input: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            
            input.value.foldMap(f.getArrow)
                ==
            input.value.foldLeft(.empty()) { b, a in b.combine(f.getArrow(a))
            }
        }
    }
    
    private static func rightFoldConsistentWithFoldMap() {
        property("Right fold consistent with folMap") <~ forAll { (f: ArrowOf<Int, Int>, fa: KindOf<F, Int>) in
            
            fa.value.foldMap(f.getArrow)
                ==
            fa.value.foldRight(Eval.later { .empty() }) { a, lb in lb.map { b in f.getArrow(a).combine(b) }^
            }.value()
        }
    }
    
    private static func existsConsistentWithFind() {
        property("Exists consistent with find") <~ forAll { (input: KindOf<F, Int>, predicate: ArrowOf<Int, Bool>) in
            
            input.value.exists(predicate.getArrow)
                ==
            input.value.find(predicate.getArrow)
                .fold(constant(false), constant(true))
        }
    }
    
    private static func existsIsLazy() {
        property("Exists is lazy") <~ forAll { (fa: KindOf<F, Int>) in
            var x = 0
            let _ = fa.value.exists { _ in x = 1; return true }
            let expected = fa.value.isEmpty ? 0 : 1
            return x == expected
        }
    }
    
    private static func forAllIsLazy() {
        property("ForAll is lazy") <~ forAll { (fa: KindOf<F, Int>) in
            var x = 0
            let _ = fa.value.forall { _ in x += 1; return true }
            let expected = fa.value.isEmpty ? 0 : fa.value.count
            return x == expected
        }
    }
    
    private static func forallConsistentWithExists() {
        property("Forall consistent with exists") <~ forAll { (input: KindOf<F, Int>, predicate: ArrowOf<Int, Bool>) in
            if input.value.forall(predicate.getArrow) {
                let negationExists = input.value.exists(predicate.getArrow >>> not)
                return !negationExists && (F.isEmpty(input.value) || input.value.exists(predicate.getArrow))
            } else {
                return true
            }
        }
    }
    
    private static func forallReturnsTrueIfEmpty() {
        property("Forall returns true if empty") <~ forAll { (input: KindOf<F, Int>, predicate: ArrowOf<Int, Bool>) in
            input.value.nonEmpty || input.value.forall(predicate.getArrow)
        }
    }
    
    private static func foldMIdIsFoldL()  {
        property("Exists consistent with find") <~ forAll { (input: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            
            input.value.foldLeft(.empty()) { b, a in b.combine(f.getArrow(a))
            }
                ==
            input.value.foldM(.empty()) { b, a in Id(b.combine(f.getArrow(a)))
            }^.value
        }
    }
}
