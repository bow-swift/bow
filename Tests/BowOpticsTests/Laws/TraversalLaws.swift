import SwiftCheck
import Bow
import BowOptics

class TraversalLaws<A: Equatable & Arbitrary, B: Equatable & Arbitrary & CoArbitrary & Hashable> {
    
    static func check(traversal: Traversal<A, B>) {
        headOption(traversal)
        modifyGetAll(traversal)
        setIdempotent(traversal)
        modifyIdentity(traversal)
        composeModify(traversal)
    }
    
    private static func headOption(_ traversal: Traversal<A, B>) {
        property("headOption") <- forAll { (a: A) in
            return traversal.headOption(a) == traversal.getAll(a).firstOrNone()
        }
    }
    
    private static func modifyGetAll(_ traversal: Traversal<A, B>) {
        property("modifyGetAll") <- forAll { (a: A, f: ArrowOf<B, B>) in
            return traversal.getAll(traversal.modify(a, f.getArrow)) == traversal.getAll(a).map(f.getArrow)
        }
    }
    
    private static func setIdempotent(_ traversal: Traversal<A, B>) {
        property("setIdempotent") <- forAll { (a: A, b: B) in
            return traversal.set(traversal.set(a, b), b) == traversal.set(a, b)
        }
    }
    
    private static func modifyIdentity(_ traversal: Traversal<A, B>) {
        property("modifyIdentity") <- forAll { (a: A) in
            return traversal.modify(a, id) == a
        }
    }
    
    private static func composeModify(_ traversal: Traversal<A, B>) {
        property("composeModify") <- forAll { (a: A, f: ArrowOf<B, B>, g: ArrowOf<B, B>) in
            return traversal.modify(traversal.modify(a, f.getArrow), g.getArrow) == traversal.modify(a, g.getArrow <<< f.getArrow)
        }
    }
}
