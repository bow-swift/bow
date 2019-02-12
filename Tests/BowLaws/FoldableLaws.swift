import SwiftCheck
@testable import Bow

class FoldableLaws<F: Foldable & EquatableK> {
    public static func check(generator: @escaping (Int) -> Kind<F, Int>) {
        leftFoldConsistentWithFoldMap(generator)
        existsConsistentWithFind(generator)
        forallConsistentWithExists(generator)
        forallReturnsTrueIfEmpty(generator)
        foldMIdIsFoldL(generator)
    }
    
    private static func leftFoldConsistentWithFoldMap(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Left fold consistent with foldMap") <- forAll { (x: Int, f: ArrowOf<Int, Int>) in
            let input = generator(x)

            return F.foldMap(input, f.getArrow) == F.foldLeft(input, Int.empty(), { b, a in b.combine(f.getArrow(a)) })
        }
    }
    
    private static func existsConsistentWithFind(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Exists consistent with find") <- forAll { (x: Int, predicate: ArrowOf<Int, Bool>) in
            let input = generator(x)
            
            return F.exists(input, predicate.getArrow) == F.find(input, predicate.getArrow).fold(constant(false), constant(true))
        }
    }
    
    private static func forallConsistentWithExists(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Forall consistent with exists") <- forAll { (x: Int, predicate: ArrowOf<Int, Bool>) in
            let input = generator(x)
            
            if F.forall(input, predicate.getArrow) {
                let negationExists = F.exists(input, predicate.getArrow >>> not)
                return !negationExists && (F.isEmpty(input) || F.exists(input, predicate.getArrow))
            } else {
                return true
            }
        }
    }
    
    private static func forallReturnsTrueIfEmpty(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Forall returns true if empty") <- forAll { (x: Int, predicate: ArrowOf<Int, Bool>) in
            let input = generator(x)
            
            return !F.isEmpty(input) || F.forall(input, predicate.getArrow)
        }
    }
    
    private static func foldMIdIsFoldL(_ generator: @escaping (Int) -> Kind<F, Int>)  {
        property("Exists consistent with find") <- forAll { (x: Int, f: ArrowOf<Int, Int>) in
            let input = generator(x)
            
            let foldL = F.foldLeft(input, Int.empty(), { b, a in b.combine(f.getArrow(a)) })
            let foldM = Id.fix(F.foldM(input, Int.empty(), { b, a in Id(b.combine(f.getArrow(a))) })).value
            return foldL == foldM
        }
    }
}
