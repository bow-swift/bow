import SwiftCheck
@testable import Bow
@testable import BowOptics

class OptionalLaws<A, B> where A : Arbitrary, B : Arbitrary, B : CoArbitrary, B : Hashable {
    
    static func check<EqA, EqB>(optional : BowOptics.Optional<A, B>, eqA : EqA, eqB : EqB) where EqA : Eq, EqA.A == A, EqB : Eq, EqB.A == B {
        getOptionSet(optional, eqA)
        setGetOption(optional, Option<B>.eq(eqB))
        setIdempotent(optional, eqA)
        modifyId(optional, eqA)
        composeModify(optional, eqA)
        consistentSetModify(optional, eqA)
        consistentModifyModifyFId(optional, eqA)
        consistentGetOptionModifyFId(optional, Option<B>.eq(eqB))
    }
    
    private static func getOptionSet<EqA>(_ optional : BowOptics.Optional<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("getOption - set") <- forAll { (a : A) in
            return eqA.eqv(optional.getOrModify(a).fold(id, { b in optional.set(a, b)}),
                           a)
        }
    }
    
    private static func setGetOption<EqOptionB>(_ optional : BowOptics.Optional<A, B>, _ eqB : EqOptionB) where EqOptionB : Eq, EqOptionB.A == OptionOf<B> {
        property("set - getOption") <- forAll { (a : A, b : B) in
            return eqB.eqv(optional.getOption(optional.set(a, b)),
                           optional.getOption(a).map(constant(b)))
        }
    }
    
    private static func setIdempotent<EqA>(_ optional : BowOptics.Optional<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("set idempotent") <- forAll { (a : A, b : B) in
            return eqA.eqv(optional.set(optional.set(a, b), b),
                           optional.set(a, b))
        }
    }
    
    private static func modifyId<EqA>(_ optional : BowOptics.Optional<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("modify id") <- forAll { (a : A) in
            return eqA.eqv(optional.modify(a, id), a)
        }
    }
    
    private static func composeModify<EqA>(_ optional : BowOptics.Optional<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("compose modify") <- forAll { (a : A, f : ArrowOf<B, B>, g : ArrowOf<B, B>) in
            return eqA.eqv(optional.modify(optional.modify(a, f.getArrow), g.getArrow),
                           optional.modify(a, g.getArrow <<< f.getArrow))
        }
    }
    
    private static func consistentSetModify<EqA>(_ optional : BowOptics.Optional<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Consistent set - modify") <- forAll { (a : A, b : B) in
            return eqA.eqv(optional.set(a, b),
                           optional.modify(a, constant(b)))
        }
    }
    
    private static func consistentModifyModifyFId<EqA>(_ optional : BowOptics.Optional<A, B>, _ eqA : EqA) where EqA : Eq, EqA.A == A {
        property("Consistent modify - modifyF Id") <- forAll { (a : A, f : ArrowOf<B, B>) in
            return eqA.eqv(optional.modify(a, f.getArrow),
                           optional.modifyF(Id<B>.applicative(), a, { b in Id<B>.pure(f.getArrow(b)) }).fix().value)
        }
    }
    
    private static func consistentGetOptionModifyFId<EqOptionB>(_ optional : BowOptics.Optional<A, B>, _ eqB : EqOptionB) where EqOptionB : Eq, EqOptionB.A == OptionOf<B> {
        
        property("Consistent getOption - modifyF Id") <- forAll { (a : A) in
            return eqB.eqv(Const<FirstOption<B>, A>.fix(optional.modifyF(Const<FirstOption<B>, B>.applicative(OptionalMonoid<B>()), a, { b in Const<FirstOption<B>, B>.pure(FirstOption<B>(Option<B>.some(b))) })).value.option,
                           optional.getOption(a))
        }
    }
    
}

fileprivate class FirstOption<B> {
    let option : Option<B>
    
    init(_ option : Option<B>) {
        self.option = option
    }
}

fileprivate class OptionalMonoid<B> : Monoid {
    typealias A = FirstOption<B>
    
    var empty: FirstOption<B> {
        return FirstOption<B>(Option<B>.none())
    }
    
    func combine(_ a: FirstOption<B>, _ b: FirstOption<B>) -> FirstOption<B> {
        return a.option.fold(constant(false), constant(true)) ? a : b
    }
}
