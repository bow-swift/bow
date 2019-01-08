import SwiftCheck
@testable import Bow

class FoldableLaws<F> {
    public static func check<FoldableType>(foldable : FoldableType, generator : @escaping (Int) -> Kind<F, Int>) where FoldableType : Foldable, FoldableType.F == F {
        leftFoldConsistentWithFoldMap(foldable, generator)
        existsConsistentWithFind(foldable, generator)
        forallConsistentWithExists(foldable, generator)
        forallReturnsTrueIfEmpty(foldable, generator)
        foldMIdIsFoldL(foldable, generator)
    }
    
    private static func leftFoldConsistentWithFoldMap<FoldableType>(_ foldable : FoldableType, _ generator : @escaping (Int) -> Kind<F, Int>) where FoldableType : Foldable, FoldableType.F == F {
        property("Left fold consistent with foldMap") <- forAll { (x : Int, f : ArrowOf<Int, Int>) in
            let input = generator(x)
            
            return foldable.foldMap(Int.sumMonoid, input, f.getArrow) ==
                foldable.foldLeft(input, Int.sumMonoid.empty, { b, a in Int.sumMonoid.combine(b, f.getArrow(a)) })
        }
    }
    
    private static func existsConsistentWithFind<FoldableType>(_ foldable : FoldableType, _ generator : @escaping (Int) -> Kind<F, Int>) where FoldableType : Foldable, FoldableType.F == F {
        property("Exists consistent with find") <- forAll { (x : Int, predicate : ArrowOf<Int, Bool>) in
            let input = generator(x)
            
            return foldable.exists(input, predicate.getArrow) ==
                    foldable.find(input, predicate.getArrow).fold(constant(false), constant(true))
        }
    }
    
    private static func forallConsistentWithExists<FoldableType>(_ foldable : FoldableType, _ generator : @escaping (Int) -> Kind<F, Int>) where FoldableType : Foldable, FoldableType.F == F {
        property("Forall consistent with exists") <- forAll { (x : Int, predicate : ArrowOf<Int, Bool>) in
            let input = generator(x)
            
            if foldable.forall(input, predicate.getArrow) {
                let negationExists = foldable.exists(input, predicate.getArrow >>> not)
                return !negationExists && (foldable.isEmpty(input) || foldable.exists(input, predicate.getArrow))
            } else {
                return true
            }
        }
    }
    
    private static func forallReturnsTrueIfEmpty<FoldableType>(_ foldable : FoldableType, _ generator : @escaping (Int) -> Kind<F, Int>) where FoldableType : Foldable, FoldableType.F == F {
        property("Forall returns true if empty") <- forAll { (x : Int, predicate : ArrowOf<Int, Bool>) in
            let input = generator(x)
            
            return !foldable.isEmpty(input) || foldable.forall(input, predicate.getArrow)
        }
    }
    
    private static func foldMIdIsFoldL<FoldableType>(_ foldable : FoldableType, _ generator : @escaping (Int) -> Kind<F, Int>) where FoldableType : Foldable, FoldableType.F == F {
        property("Exists consistent with find") <- forAll { (x : Int, f : ArrowOf<Int, Int>) in
            let input = generator(x)
            
            let foldL = foldable.foldLeft(input, Int.sumMonoid.empty, { b, a in Int.sumMonoid.combine(b, f.getArrow(a)) })
            let foldM = foldable.foldM(input, Int.sumMonoid.empty, { b, a in Id(Int.sumMonoid.combine(b, f.getArrow(a))) }, Id<Int>.monad()).fix().value
            return foldL == foldM
        }
    }
}
