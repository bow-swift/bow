import XCTest
import BowLaws
import Bow

extension EnvTPartial: EquatableK where E: Equatable, W: Comonad & EquatableK {
    public static func eq<A: Equatable>(_ lhs: EnvTOf<E, W, A>,
                                        _ rhs: EnvTOf<E, W, A>) -> Bool {
        let (le, la) = lhs^.runT()
        let (re, ra) = rhs^.runT()
        return le == re && la == ra
    }
}

class EnvTTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<EnvPartial<Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<EnvPartial<Int>>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<EnvPartial<Int>>.check()
    }
}
