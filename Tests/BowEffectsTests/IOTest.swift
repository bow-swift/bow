import XCTest
import SwiftCheck
@testable import BowLaws
import Bow
import BowEffects
import BowEffectsGenerators
import BowEffectsLaws

class IOTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<IOPartial<CategoryError>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<IOPartial<CategoryError>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<IOPartial<CategoryError>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<IOPartial<CategoryError>>.check()
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
