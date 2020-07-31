import SwiftCheck
import Bow
import BowOptics
import BowLaws

public class AffineTraversalLaws<A: Equatable & Arbitrary, B: Equatable & Arbitrary & CoArbitrary & Hashable> {
    
    public static func check(affineTraversal: AffineTraversal<A, B>) {
        getOptionSet(affineTraversal)
        setGetOption(affineTraversal)
        setIdempotent(affineTraversal)
        modifyId(affineTraversal)
        composeModify(affineTraversal)
        consistentSetModify(affineTraversal)
        consistentModifyModifyFId(affineTraversal)
    }
    
    private static func getOptionSet(_ affineTraversal: AffineTraversal<A, B>) {
        property("getOption - set") <~ forAll { (a: A) in
            return affineTraversal.getOrModify(a).fold(id, { b in affineTraversal.set(a, b)}) == a
        }
    }
    
    private static func setGetOption(_ affineTraversal: AffineTraversal<A, B>) {
        property("set - getOption") <~ forAll { (a: A, b: B) in
            return affineTraversal.getOption(affineTraversal.set(a, b)) ==
                affineTraversal.getOption(a).map(constant(b))
        }
    }
    
    private static func setIdempotent(_ affineTraversal: AffineTraversal<A, B>) {
        property("set idempotent") <~ forAll { (a: A, b: B) in
            return affineTraversal.set(affineTraversal.set(a, b), b) == affineTraversal.set(a, b)
        }
    }
    
    private static func modifyId(_ affineTraversal: AffineTraversal<A, B>) {
        property("modify id") <~ forAll { (a: A) in
            return affineTraversal.modify(a, id) == a
        }
    }
    
    private static func composeModify(_ affineTraversal: AffineTraversal<A, B>) {
        property("compose modify") <~ forAll { (a: A, f: ArrowOf<B, B>, g: ArrowOf<B, B>) in
            return affineTraversal.modify(affineTraversal.modify(a, f.getArrow), g.getArrow) ==
                affineTraversal.modify(a, g.getArrow <<< f.getArrow)
        }
    }
    
    private static func consistentSetModify(_ affineTraversal: AffineTraversal<A, B>) {
        property("Consistent set - modify") <~ forAll { (a: A, b: B) in
            return affineTraversal.set(a, b) == affineTraversal.modify(a, constant(b))
        }
    }
    
    private static func consistentModifyModifyFId(_ affineTraversal: AffineTraversal<A, B>) {
        property("Consistent modify - modifyF Id") <~ forAll { (a: A, f: ArrowOf<B, B>) in
            return affineTraversal.modify(a, f.getArrow) ==
                affineTraversal.modifyF(a, { b in Id<B>.pure(f.getArrow(b)) })^.value
        }
    }
}
