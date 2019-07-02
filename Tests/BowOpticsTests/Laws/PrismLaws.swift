import SwiftCheck
import Bow
import BowOptics

class PrismLaws<A: Arbitrary & Equatable, B: Arbitrary & CoArbitrary & Hashable & Equatable> {
    
    static func check(prism: Prism<A, B>) {
        partialRoundTripOneWay(prism)
        roundTripOtherWay(prism)
        modifyId(prism)
        composeModify(prism)
        consistentSetModify(prism)
        consistentModifyModifyFId(prism)
    }
    
    private static func partialRoundTripOneWay(_ prism : Prism<A, B>) {
        property("Partial round trip one way") <- forAll { (a : A) in
            return prism.getOrModify(a).fold(id, prism.reverseGet) == a
        }
    }
    
    private static func roundTripOtherWay(_ prism : Prism<A, B>) {
        property("Round trip other way") <- forAll { (b : B) in
            return prism.getOption(prism.reverseGet(b)) == Option.some(b)
        }
    }
    
    private static func modifyId(_ prism : Prism<A, B>) {
        property("Modify id") <- forAll { (a : A) in
            return prism.modify(a, id) == a
        }
    }
    
    private static func composeModify(_ prism : Prism<A, B>) {
        property("Compose modify") <- forAll { (a : A, f : ArrowOf<B, B>, g : ArrowOf<B, B>) in
            return prism.modify(prism.modify(a, f.getArrow), g.getArrow) ==
                prism.modify(a, g.getArrow <<< f.getArrow)
        }
    }
    
    private static func consistentSetModify(_ prism : Prism<A, B>) {
        property("Consistent set - modify") <- forAll { (a : A, b : B) in
            return prism.set(a, b) == prism.modify(a, constant(b))
        }
    }
    
    private static func consistentModifyModifyFId(_ prism : Prism<A, B>) {
        property("Consistent modify - modifyF Id") <- forAll { (a : A, f : ArrowOf<B, B>) in
            return prism.modify(a, f.getArrow) == Id.fix(prism.modifyF(a, { b in Id(f.getArrow(b)) })).value
        }
    }
}
