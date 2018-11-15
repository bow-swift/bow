import XCTest
@testable import BowLaws
@testable import Bow

class Function0Test: XCTestCase {
    
    var generator : (Int) -> Function0Of<Int> {
        return { a in Function0.pure(a) }
    }
    
    let eq = Function0.eq(Int.order)
    let eqUnit = Function0.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForFunction0>.check(functor: Function0<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForFunction0>.check(applicative: Function0<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<ForFunction0>.check(monad: Function0<Int>.monad(), eq: self.eq)
    }
    
    func testComonadLaws() {
        ComonadLaws<ForFunction0>.check(comonad: Function0<Int>.comonad(), generator: self.generator, eq: self.eq)
    }
    
    func testBimonadLaws() {
        BimonadLaws<ForFunction0>.check(bimonad: Function0<Int>.bimonad(), generator: self.generator, eq: self.eq)
    }
}
