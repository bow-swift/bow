import SwiftCheck
import Bow
import BowOptics

public class LensLaws<A: Equatable & Arbitrary, B: Equatable & Arbitrary & CoArbitrary & Hashable & Monoid> {
    
    public static func check(lens: Lens<A, B>) {
        getSet(lens)
        setGet(lens)
        setIdempotent(lens)
        modifyId(lens)
        composeModify(lens)
        consistentSetModify(lens)
        consistentModifyModifyFId(lens)
        consistentGetModifyFId(lens)
    }
    
    private static func getSet(_ lens: Lens<A, B>)  {
        property("get set") <- forAll { (a: A) in
            return lens.set(a, lens.get(a)) == a
        }
    }
    
    private static func setGet(_ lens: Lens<A, B>) {
        property("set get") <- forAll { (a: A, b: B) in
            return lens.get(lens.set(a, b)) == b
        }
    }
    
    private static func setIdempotent(_ lens: Lens<A, B>) {
        property("Set idempotent") <- forAll { (a: A, b: B) in
            return lens.set(lens.set(a, b), b) == lens.set(a, b)
        }
    }
    
    private static func modifyId(_ lens: Lens<A, B>) {
        property("Modify id") <- forAll { (a: A) in
            return lens.modify(a, id) == a
        }
    }
    
    private static func composeModify(_ lens: Lens<A, B>) {
        property("Compose modify") <- forAll { (a: A, f: ArrowOf<B, B>, g: ArrowOf<B, B>) in
            return lens.modify(lens.modify(a, f.getArrow), g.getArrow) ==
                lens.modify(a, g.getArrow <<< f.getArrow)
        }
    }
    
    private static func consistentSetModify(_ lens: Lens<A, B>) {
        property("Consistent set - modify") <- forAll { (a: A, b: B) in
            return lens.set(a, b) == lens.modify(a, constant(b))
        }
    }
    
    private static func consistentModifyModifyFId(_ lens: Lens<A, B>) {
        property("Consistent modify - modifyF Id") <- forAll { (a: A, f: ArrowOf<B, B>) in
            return lens.modify(a, f.getArrow) ==
                Id.fix(lens.modifyF(a, { b in Id.pure(f.getArrow(b)) })).value
        }
    }
    
    private static func consistentGetModifyFId(_ lens: Lens<A, B>)  {
        property("Consistent get - modifyF Id") <- forAll { (a: A) in
            return lens.get(a) == Const<B, A>.fix(lens.modifyF(a, Const<B, B>.init)).value
        }
    }
}
