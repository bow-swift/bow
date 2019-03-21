import XCTest
@testable import BowLaws
@testable import Bow
@testable import BowRx
@testable import BowEffectsLaws

extension ForSingleK: EquatableK {
    public static func eq<A: Equatable>(_ lhs: Kind<ForSingleK, A>, _ rhs: Kind<ForSingleK, A>) -> Bool {
        return SingleK.fix(lhs).value.blockingGet() == SingleK.fix(rhs).value.blockingGet()
    }
}

class SingleKTest: XCTestCase {
    let generator = { (x: Int) in SingleK.pure(x) }

    func testFunctorLaws() {
        FunctorLaws<ForSingleK>.check(generator: generator)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForSingleK>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ForSingleK>.check()
    }

    func testMonadLaws() {
        MonadLaws<ForSingleK>.check()
    }
}
