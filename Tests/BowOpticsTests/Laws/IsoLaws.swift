import SwiftCheck
import Bow
import BowOptics

class IsoLaws<A: Equatable & Arbitrary, B: Equatable & Arbitrary & CoArbitrary & Hashable & Monoid> {
    
    static func check(iso: Iso<A, B>) {
        roundTripOneWay(iso)
        roundTripOtherWay(iso)
        modifyIdentity(iso)
        composeModify(iso)
        consistentSetModify(iso)
        consistentModifyModifyFId(iso)
        consistentGetModifyFId(iso)
    }
    
    private static func roundTripOneWay(_ iso: Iso<A, B>) {
        property("Round trip one way") <- forAll { (a: A) in
            return iso.reverseGet(iso.get(a)) == a
        }
    }
    
    private static func roundTripOtherWay(_ iso: Iso<A, B>) {
        property("Round trip other way") <- forAll { (b: B) in
            return iso.get(iso.reverseGet(b)) == b
        }
    }
    
    private static func modifyIdentity(_ iso: Iso<A, B>) {
        property("Modify identiy") <- forAll { (a: A) in
            return iso.modify(a, id) == a
        }
    }
    
    private static func composeModify(_ iso: Iso<A, B>) {
        property("Compose modify") <- forAll { (a: A, f: ArrowOf<B, B>, g: ArrowOf<B, B>) in
            return iso.modify(iso.modify(a, f.getArrow), g.getArrow) ==
                iso.modify(a, g.getArrow <<< f.getArrow)
        }
    }
    
    private static func consistentSetModify(_ iso: Iso<A, B>) {
        property("Consistent set-modify") <- forAll { (a: A, b: B) in
            return iso.set(b) == iso.modify(a, constant(b))
        }
    }
    
    private static func consistentModifyModifyFId(_ iso: Iso<A, B>) {
        property("Consistent modify - modifyF Id") <- forAll { (a: A, f: ArrowOf<B, B>) in
            return iso.modify(a, f.getArrow) == Id.fix(iso.modifyF(a, { b in Id<B>.pure(f.getArrow(b)) })).value
        }
    }
    
    private static func consistentGetModifyFId(_ iso: Iso<A, B>) {
        property("Consistent get - modifyF Id") <- forAll { (a: A) in
            return iso.get(a) == Const.fix(iso.modifyF(a, Const<B, B>.init)).value
        }
    }
}
