import XCTest
@testable import BowLaws
@testable import Bow
@testable import BowRx
@testable import BowEffectsLaws

extension ForObservableK: EquatableK {
    public static func eq<A: Equatable>(_ lhs: Kind<ForObservableK, A>, _ rhs: Kind<ForObservableK, A>) -> Bool {
        return ObservableK.fix(lhs).value.blockingGet() == ObservableK.fix(rhs).value.blockingGet()
    }
}

class ObservableKTest: XCTestCase {
    let generator = { (x : Int) -> ObservableKOf<Int> in ObservableK.pure(x) }
    
    func testFunctorLaws() {
        FunctorLaws<ForObservableK>.check(generator: generator)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForObservableK>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<ForObservableK>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForObservableK>.check(generator: generator)
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForObservableK>.check(generator: generator)
    }
}
