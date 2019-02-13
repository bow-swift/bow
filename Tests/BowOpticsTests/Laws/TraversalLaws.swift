import SwiftCheck
@testable import Bow
@testable import BowOptics

class TraversalLaws<A: Equatable, B: Equatable & Arbitrary & CoArbitrary & Hashable> {
    
    static func check(traversal: Traversal<A, B>, generatorA: Gen<A>) {
        headOption(traversal, generatorA)
        modifyGetAll(traversal, generatorA)
        setIdempotent(traversal, generatorA)
        modifyIdentity(traversal, generatorA)
        composeModify(traversal, generatorA)
    }
    
    private static func headOption(_ traversal: Traversal<A, B>, _ generatorA: Gen<A>) {
        property("headOption") <- forAll { (_ : Int) in
            let a = generatorA.generate
            return traversal.headOption(a) == traversal.getAll(a).firstOrNone()
        }
    }
    
    private static func modifyGetAll(_ traversal: Traversal<A, B>, _ generatorA: Gen<A>) {
        property("modifyGetAll") <- forAll { (f : ArrowOf<B, B>) in
            let a = generatorA.generate
            return traversal.getAll(traversal.modify(a, f.getArrow)) == traversal.getAll(a).map(f.getArrow)
        }
    }
    
    private static func setIdempotent(_ traversal: Traversal<A, B>, _ generatorA: Gen<A>) {
        property("setIdempotent") <- forAll { (b : B) in
            let a = generatorA.generate
            return traversal.set(traversal.set(a, b), b) == traversal.set(a, b)
        }
    }
    
    private static func modifyIdentity(_ traversal: Traversal<A, B>, _ generatorA: Gen<A>) {
        property("modifyIdentity") <- forAll { (_ : Int) in
            let a = generatorA.generate
            return traversal.modify(a, id) == a
        }
    }
    
    private static func composeModify(_ traversal: Traversal<A, B>, _ generatorA: Gen<A>) {
        property("composeModify") <- forAll { (f : ArrowOf<B, B>, g : ArrowOf<B, B>) in
            let a = generatorA.generate
            return traversal.modify(traversal.modify(a, f.getArrow), g.getArrow) == traversal.modify(a, g.getArrow <<< f.getArrow)
        }
    }
}
