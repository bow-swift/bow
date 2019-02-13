import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow
@testable import BowEffects
@testable import BowEffectsLaws

class IOTest: XCTestCase {
    
    let generator = { (a : Int) in IO<CategoryError, Int>.pure(a) }

    func testEquatableLaws() {
        EquatableKLaws.check(generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<IOPartial<CategoryError>>.check(generator: self.generator)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<IOPartial<CategoryError>>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<IOPartial<CategoryError>>.check()
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<IOPartial<CategoryError>>.check()
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<IOPartial<CategoryError>>.check()
    }
    
    func testAsyncContextLaws() {
        AsyncLaws<IOPartial<CategoryError>>.check()
    }
}
