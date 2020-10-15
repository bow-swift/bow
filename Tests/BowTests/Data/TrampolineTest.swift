import XCTest
import SwiftCheck
import BowLaws
import Bow

extension TrampolinePartial: EquatableK {
    public static func eq<A>(_ lhs: TrampolineOf<A>, _ rhs: TrampolineOf<A>) -> Bool where A : Equatable {
        lhs^.run() == rhs^.run()
    }
}

class TrampolineTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<TrampolinePartial>.check()
    }

    func testApplicativeLaws() {
        ApplicativeLaws<TrampolinePartial>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<TrampolinePartial>.check()
    }

    func testMonadLaws() {
        MonadLaws<TrampolinePartial>.check()
    }
    
    func testDoesNotCrashStack() {
        XCTAssert(isEven(200000))
    }
    
    func isEven(_ n: Int) -> Bool {
        _isEven(n).run()
    }
    
    func _isEven(_ n: Int) -> Trampoline<Bool> {
        if n == 0 {
            return .done(true)
        } else if n == 1 {
            return .done(false)
        } else {
            return .defer { self._isOdd(n - 1) }
        }
    }
    
    func _isOdd(_ n: Int) -> Trampoline<Bool> {
        if n == 0 {
            return .done(false)
        } else if n == 1 {
            return .done(true)
        } else {
            return .defer { self._isEven(n - 1) }
        }
    }
}
