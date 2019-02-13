import XCTest
@testable import BowLaws
@testable import Bow
@testable import BowRx
@testable import BowEffectsLaws

extension ForMaybeK: EquatableK {
    public static func eq<A: Equatable>(_ lhs: Kind<ForMaybeK, A>, _ rhs: Kind<ForMaybeK, A>) -> Bool {
        return MaybeK.fix(lhs).value.blockingGet() == MaybeK.fix(rhs).value.blockingGet()
    }
}

class MaybeKTest: XCTestCase {
    let generator = { (x : Int) in MaybeK.pure(x) }
    
    func testFunctorLaws() {
        FunctorLaws<ForMaybeK>.check(generator: generator)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForMaybeK>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<ForMaybeK>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForMaybeK>.check(generator: generator)
    }
}
