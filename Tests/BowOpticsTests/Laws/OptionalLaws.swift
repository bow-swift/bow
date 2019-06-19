import SwiftCheck
import Bow
import BowOptics

class OptionalLaws<A: Equatable & Arbitrary, B: Equatable & Arbitrary & CoArbitrary & Hashable> {
    
    static func check(optional: BowOptics.Optional<A, B>) {
        getOptionSet(optional)
        setGetOption(optional)
        setIdempotent(optional)
        modifyId(optional)
        composeModify(optional)
        consistentSetModify(optional)
        consistentModifyModifyFId(optional)
    }
    
    private static func getOptionSet(_ optional: BowOptics.Optional<A, B>) {
        property("getOption - set") <- forAll { (a: A) in
            return optional.getOrModify(a).fold(id, { b in optional.set(a, b)}) == a
        }
    }
    
    private static func setGetOption(_ optional: BowOptics.Optional<A, B>) {
        property("set - getOption") <- forAll { (a: A, b: B) in
            return optional.getOption(optional.set(a, b)) ==
                optional.getOption(a).map(constant(b))
        }
    }
    
    private static func setIdempotent(_ optional: BowOptics.Optional<A, B>) {
        property("set idempotent") <- forAll { (a: A, b: B) in
            return optional.set(optional.set(a, b), b) == optional.set(a, b)
        }
    }
    
    private static func modifyId(_ optional: BowOptics.Optional<A, B>) {
        property("modify id") <- forAll { (a: A) in
            return optional.modify(a, id) == a
        }
    }
    
    private static func composeModify(_ optional: BowOptics.Optional<A, B>) {
        property("compose modify") <- forAll { (a: A, f: ArrowOf<B, B>, g: ArrowOf<B, B>) in
            return optional.modify(optional.modify(a, f.getArrow), g.getArrow) ==
                optional.modify(a, g.getArrow <<< f.getArrow)
        }
    }
    
    private static func consistentSetModify(_ optional: BowOptics.Optional<A, B>) {
        property("Consistent set - modify") <- forAll { (a: A, b: B) in
            return optional.set(a, b) == optional.modify(a, constant(b))
        }
    }
    
    private static func consistentModifyModifyFId(_ optional: BowOptics.Optional<A, B>) {
        property("Consistent modify - modifyF Id") <- forAll { (a: A, f: ArrowOf<B, B>) in
            return optional.modify(a, f.getArrow) ==
                Id.fix(optional.modifyF(a, { b in Id<B>.pure(f.getArrow(b)) })).value
        }
    }
}
