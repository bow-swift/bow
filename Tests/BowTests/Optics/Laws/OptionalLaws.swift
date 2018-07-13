import SwiftCheck
@testable import Bow

class OptionalLaws<A, B> where A : Arbitrary, B : Arbitrary, B : CoArbitrary, B : Hashable {
    
    static func check<EqA, EqB>(optional : Bow.Optional<A, B>, eqA : EqA, eqB : EqB) where EqA : Eq, EqA.A == A, EqB : Eq, EqB.A == B {
        getMaybeSet(optional, eqA)
        setGetMaybe(optional, Maybe<B>.eq(eqB))
        setIdempotent(optional, eqA)
        modifyId(optional, eqA)
        composeModify(optional, eqA)
        consistentSetModify(optional, eqA)
        consistentModifyModifyFId(optional, eqA)
        consistentGetMaybeModifyFId(optional, Maybe<B>.eq(eqB))
    }
    
    private static func getMaybeSet<EqA>(_ optional : Bow.Optional<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("getMaybe - set") <- forAll { (a : A) in
            return eqA.eqv(optional.getOrModify(a).fold(id, { b in optional.set(a, b)}),
                           a)
        }
    }
    
    private static func setGetMaybe<EqMaybeB>(_ optional : Bow.Optional<A, B>, _ eqB : EqMaybeB) where EqMaybeB : Eq, EqMaybeB.A == MaybeOf<B> {
        property("set - getMaybe") <- forAll { (a : A, b : B) in
            return eqB.eqv(optional.getMaybe(optional.set(a, b)),
                           optional.getMaybe(a).map(constant(b)))
        }
    }
    
    private static func setIdempotent<EqA>(_ optional : Bow.Optional<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("set idempotent") <- forAll { (a : A, b : B) in
            return eqA.eqv(optional.set(optional.set(a, b), b),
                           optional.set(a, b))
        }
    }
    
    private static func modifyId<EqA>(_ optional : Bow.Optional<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("modify id") <- forAll { (a : A) in
            return eqA.eqv(optional.modify(a, id), a)
        }
    }
    
    private static func composeModify<EqA>(_ optional : Bow.Optional<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("compose modify") <- forAll { (a : A, f : ArrowOf<B, B>, g : ArrowOf<B, B>) in
            return eqA.eqv(optional.modify(optional.modify(a, f.getArrow), g.getArrow),
                           optional.modify(a, g.getArrow <<< f.getArrow))
        }
    }
    
    private static func consistentSetModify<EqA>(_ optional : Bow.Optional<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Consistent set - modify") <- forAll { (a : A, b : B) in
            return eqA.eqv(optional.set(a, b),
                           optional.modify(a, constant(b)))
        }
    }
    
    private static func consistentModifyModifyFId<EqA>(_ optional : Bow.Optional<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Consistent modify - modifyF Id") <- forAll { (a : A, f : ArrowOf<B, B>) in
            return eqA.eqv(optional.modify(a, f.getArrow),
                           optional.modifyF(Id<B>.applicative(), a, { b in Id<B>.pure(f.getArrow(b)) }).fix().value)
        }
    }
    
    private static func consistentGetMaybeModifyFId<EqMaybeB>(_ optional : Bow.Optional<A, B>, _ eqB : EqMaybeB) where EqMaybeB : Eq, EqMaybeB.A == MaybeOf<B> {
        
        property("Consistent getMaybe - modifyF Id") <- forAll { (a : A) in
            return eqB.eqv(Const<FirstMaybe<B>, A>.fix(optional.modifyF(Const<FirstMaybe<B>, B>.applicative(OptionalMonoid<B>()), a, { b in Const<FirstMaybe<B>, B>.pure(FirstMaybe<B>(Maybe<B>.some(b))) })).value.maybe,
                           optional.getMaybe(a))
        }
    }
    
}

fileprivate class FirstMaybe<B> {
    let maybe : Maybe<B>
    
    init(_ maybe : Maybe<B>) {
        self.maybe = maybe
    }
}

fileprivate class OptionalMonoid<B> : Monoid {
    typealias A = FirstMaybe<B>
    
    var empty: FirstMaybe<B> {
        return FirstMaybe<B>(Maybe<B>.none())
    }
    
    func combine(_ a: FirstMaybe<B>, _ b: FirstMaybe<B>) -> FirstMaybe<B> {
        return a.maybe.fold(constant(false), constant(true)) ? a : b
    }
}
