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
    
    func testFoldableLaws() {
        FoldableLaws<EnvTPartial<Int, NEAPartial>>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<EnvTPartial<Int, NEAPartial>>.check()
    }
    
    func testComonadEnvLaws() {
        ComonadEnvLaws<EnvPartial<Int>, Int>.check()
    }
    
    func testComonadStoreLaws() {
        ComonadStoreLaws<EnvTPartial<Int, StorePartial<Int>>, Int>.check()
    }
    
    func testComonadTracedLaws() {
        ComonadTracedLaws<EnvTPartial<Int, TracedPartial<Int>>, Int>.check()
    }
}
