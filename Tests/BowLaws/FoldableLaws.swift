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
            return F.foldMap(input.value, f.getArrow) == F.foldLeft(input.value, Int.empty(), { b, a in b.combine(f.getArrow(a)) })
        }
    }
    
    private static func rightFoldConsistentWithFoldMap() {
        property("Right fold consistent with folMap") <~ forAll { (f: ArrowOf<Int, Int>, fa: KindOf<F, Int>) in
            return fa.value.foldMap(f.getArrow) ==
                fa.value.foldRight(Eval.later { Int.empty() }, { a, lb in lb.map { b in f.getArrow(a).combine(b) }^ }).value()
        }
    }
    
    private static func existsConsistentWithFind() {
        property("Exists consistent with find") <~ forAll { (input: KindOf<F, Int>, predicate: ArrowOf<Int, Bool>) in
            return F.exists(input.value, predicate.getArrow) == F.find(input.value, predicate.getArrow).fold(constant(false), constant(true))
        }
    }
    
    private static func existsIsLazy() {
        property("Exists is lazy") <~ forAll { (fa: KindOf<F, Int>) in
            var x = 0
            let _ = fa.value.exists { _ in x += 1; return true }
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
            if F.forall(input.value, predicate.getArrow) {
                let negationExists = F.exists(input.value, predicate.getArrow >>> not)
                return !negationExists && (F.isEmpty(input.value) || F.exists(input.value, predicate.getArrow))
            } else {
                return true
            }
        }
    }
    
    private static func forallReturnsTrueIfEmpty() {
        property("Forall returns true if empty") <~ forAll { (input: KindOf<F, Int>, predicate: ArrowOf<Int, Bool>) in
            return !F.isEmpty(input.value) || F.forall(input.value, predicate.getArrow)
        }
    }
    
    private static func foldMIdIsFoldL()  {
        property("Exists consistent with find") <~ forAll { (input: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            let foldL = F.foldLeft(input.value, Int.empty(), { b, a in b.combine(f.getArrow(a)) })
            let foldM = Id.fix(F.foldM(input.value, Int.empty(), { b, a in Id(b.combine(f.getArrow(a))) })).value
            return foldL == foldM
        }
    }
}
