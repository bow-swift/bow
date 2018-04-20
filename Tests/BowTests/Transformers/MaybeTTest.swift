import XCTest
@testable import Bow

class MaybeTTest: XCTestCase {
    
    var generator : (Int) -> MaybeTOf<ForId, Int> {
        return { a in MaybeT<ForId, Int>.pure(a, Id<Any>.applicative()) }
    }
    
    let eq = MaybeT.eq(Id.eq(Maybe.eq(Int.order)), Id<Any>.functor())
    let eqUnit = MaybeT.eq(Id.eq(Maybe.eq(UnitEq())), Id<Any>.functor())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<MaybeTPartial<ForId>>.check(functor: MaybeT<ForId, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<MaybeTPartial<ForId>>.check(applicative: MaybeT<ForId, Int>.applicative(Id<Any>.monad()), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<MaybeTPartial<ForId>>.check(monad: MaybeT<ForId, Int>.monad(Id<Any>.monad()), eq: self.eq)
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<MaybeTPartial<ForId>>.check(semigroupK: MaybeT<ForId, Int>.semigroupK(Id<Any>.monad()), generator: self.generator, eq: self.eq)
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<MaybeTPartial<ForId>>.check(monoidK: MaybeT<ForId, Int>.monoidK(Id<Any>.monad()), generator: self.generator, eq: self.eq)
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<MaybeTPartial<ForId>>.check(functorFilter: MaybeT<ForId, Int>.functorFilter(Id<Any>.functor()), generator: self.generator, eq: self.eq)
    }
}
