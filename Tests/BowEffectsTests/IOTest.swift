import XCTest
import SwiftCheck
@testable import BowLaws
import Bow
@testable import BowEffects
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
    
    func testMonadDeferLaws() {
        MonadDeferLaws<IOPartial<CategoryError>>.check()
    }
    
    func testAsyncLaws() {
        AsyncLaws<IOPartial<CategoryError>>.check()
    }
    
    func testBracketLaws() {
        BracketLaws<IOPartial<CategoryError>>.check()
    }
}

extension IOPartial: EquatableK where E: Equatable {
    public static func eq<A: Equatable>(_ lhs: IOOf<E, A>, _ rhs: IOOf<E, A>) -> Bool {
        let x = lhs^.unsafeRunSyncEither()
        let y = rhs^.unsafeRunSyncEither()
        return x == y
    }
}
