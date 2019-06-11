import XCTest
import SwiftCheck
@testable import BowLaws
import Bow

extension StateTPartial: EquatableK where F: EquatableK & Monad, S == Int {
    public static func eq<A>(_ lhs: Kind<StateTPartial<F, S>, A>, _ rhs: Kind<StateTPartial<F, S>, A>) -> Bool where A : Equatable {
        let x = StateT.fix(lhs).runM(1)
        let y = StateT.fix(rhs).runM(1)
        return isEqual(x, y)
    }
}

class StateTTest: XCTestCase {
    var generator: (Int) -> StateTOf<ForId, Int, Int> {
        return { a in StateT<ForId, Int, Int>.pure(a) }
    }
    
    func testFunctorLaws() {
        FunctorLaws<StateTPartial<ForId, Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<StateTPartial<ForId, Int>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<StateTPartial<ForId, Int>>.check()
    }

    func testMonadLaws() {
        MonadLaws<StateTPartial<ForId, Int>>.check()
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<StateTPartial<EitherPartial<CategoryError>, Int>>.check()
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<StateTPartial<EitherPartial<CategoryError>, Int>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<StateTPartial<ForArrayK, Int>>.check(generator: { (a : Int) in StateT<ForArrayK, Int, Int>.pure(a) })
    }
    
    func testMonadStateLaws() {
        MonadStateLaws<StateTPartial<ForId, Int>>.check()
    }
    
    func testMonadCombineLaws() {
        MonadCombineLaws<StateTPartial<ForArrayK, Int>>.check()
    }
}
