import XCTest
import SwiftCheck
@testable import Bow

class IdTest: XCTestCase {
    var generator : (Int) -> Id<Int> {
        return { a in Id<Int>.pure(a) }
    }
    
    let eq = Id.eq(Int.order)
    let eqUnit = Id.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForId>.check(functor: Id<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForId>.check(applicative: Id<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<ForId>.check(monad: Id<Int>.monad(), eq: self.eq)
    }
    
    func testComonadLaws() {
        ComonadLaws<ForId>.check(comonad: Id<Int>.comonad(), generator: self.generator, eq: self.eq)
    }
    
    func testShowLaws() {
        ShowLaws.check(show: Id.show(), generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForId>.check(foldable: Id<Int>.foldable(), generator: self.generator)
    }
    
    func testBimonadLaws() {
        BimonadLaws<ForId>.check(bimonad: Id<Int>.bimonad(), generator: self.generator, eq: self.eq)
    }
}
