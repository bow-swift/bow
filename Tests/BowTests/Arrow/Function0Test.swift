import XCTest
@testable import BowLaws
@testable import Bow

class Function0Test: XCTestCase {
    
    var generator: (Int) -> Function0Of<Int> {
        return { a in Function0.pure(a) }
    }

    func testEquatableLaws() {
        EquatableKLaws.check(generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForFunction0>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForFunction0>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ForFunction0>.check()
    }

    func testMonadLaws() {
        MonadLaws<ForFunction0>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<ForFunction0>.check(generator: self.generator)
    }
    
    func testBimonadLaws() {
        BimonadLaws<ForFunction0>.check(generator: self.generator)
    }
}
