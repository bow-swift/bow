import SwiftCheck
import Bow
import BowGenerators

class FoldableLaws<F: Foldable & EquatableK & ArbitraryK> {
    public static func check() {
        leftFoldConsistentWithFoldMap()
        existsConsistentWithFind()
        forallConsistentWithExists()
        forallReturnsTrueIfEmpty()
        foldMIdIsFoldL()
    }
    
    private static func leftFoldConsistentWithFoldMap() {
        property("Left fold consistent with foldMap") <- forAll { (input: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            return F.foldMap(input.value, f.getArrow) == F.foldLeft(input.value, Int.empty(), { b, a in b.combine(f.getArrow(a)) })
        }
    }
    
    private static func existsConsistentWithFind() {
        property("Exists consistent with find") <- forAll { (input: KindOf<F, Int>, predicate: ArrowOf<Int, Bool>) in
            return F.exists(input.value, predicate.getArrow) == F.find(input.value, predicate.getArrow).fold(constant(false), constant(true))
        }
    }
    
    private static func forallConsistentWithExists() {
        property("Forall consistent with exists") <- forAll { (input: KindOf<F, Int>, predicate: ArrowOf<Int, Bool>) in
            if F.forall(input.value, predicate.getArrow) {
                let negationExists = F.exists(input.value, predicate.getArrow >>> not)
                return !negationExists && (F.isEmpty(input.value) || F.exists(input.value, predicate.getArrow))
            } else {
                return true
            }
        }
    }
    
    private static func forallReturnsTrueIfEmpty() {
        property("Forall returns true if empty") <- forAll { (input: KindOf<F, Int>, predicate: ArrowOf<Int, Bool>) in
            return !F.isEmpty(input.value) || F.forall(input.value, predicate.getArrow)
        }
    }
    
    private static func foldMIdIsFoldL()  {
        property("Exists consistent with find") <- forAll { (input: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            let foldL = F.foldLeft(input.value, Int.empty(), { b, a in b.combine(f.getArrow(a)) })
            let foldM = Id.fix(F.foldM(input.value, Int.empty(), { b, a in Id(b.combine(f.getArrow(a))) })).value
            return foldL == foldM
        }
    }
}
