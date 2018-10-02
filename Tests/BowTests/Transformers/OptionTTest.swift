import XCTest
import SwiftCheck
@testable import Bow

class OptionTTest: XCTestCase {
    
    var generator : (Int) -> OptionTOf<ForId, Int> {
        return { a in OptionT<ForId, Int>.pure(a, Id<Any>.applicative()) }
    }
    
    let eq = OptionT.eq(Id.eq(Option.eq(Int.order)), Id<Any>.functor())
    let eqUnit = OptionT.eq(Id.eq(Option.eq(UnitEq())), Id<Any>.functor())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<OptionTPartial<ForId>>.check(functor: OptionT<ForId, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<OptionTPartial<ForId>>.check(applicative: OptionT<ForId, Int>.applicative(Id<Any>.monad()), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<OptionTPartial<ForId>>.check(monad: OptionT<ForId, Int>.monad(Id<Any>.monad()), eq: self.eq)
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<OptionTPartial<ForId>>.check(semigroupK: OptionT<ForId, Int>.semigroupK(Id<Any>.monad()), generator: self.generator, eq: self.eq)
    }
    
    func testSemigroupLaws() {
        property("Semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws.check(semigroup: OptionT<ForId, Int>.semigroupK(Id<Int>.monad()).algebra(),
                                       a: OptionT<ForId, Int>.pure(a, Id<Int>.applicative()),
                                       b: OptionT<ForId, Int>.pure(b, Id<Int>.applicative()),
                                       c: OptionT<ForId, Int>.pure(c, Id<Int>.applicative()),
                                       eq: self.eq)
        }
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<OptionTPartial<ForId>>.check(monoidK: OptionT<ForId, Int>.monoidK(Id<Any>.monad()), generator: self.generator, eq: self.eq)
    }
    
    func testMonoidLaws() {
        property("Monoid laws") <- forAll { (a : Int) in
            return MonoidLaws.check(monoid: OptionT<ForId, Int>.monoidK(Id<Int>.monad()).algebra(),
                                    a: OptionT<ForId, Int>.pure(a, Id<Int>.applicative()),
                                    eq: self.eq)
        }
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<OptionTPartial<ForId>>.check(functorFilter: OptionT<ForId, Int>.functorFilter(Id<Any>.functor()), generator: self.generator, eq: self.eq)
    }
}
