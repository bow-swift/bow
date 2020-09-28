import XCTest
import Bow
import BowFree
import BowFreeGenerators
import BowLaws

extension CofreePartial: EquatableK where F: EquatableK {
    public static func eq<A: Equatable>(
        _ lhs: CofreeOf<F, A>,
        _ rhs: CofreeOf<F, A>
    ) -> Bool {
        lhs^.head == rhs^.head &&
        lhs^.tail == rhs^.tail
    }
}

class CofreeTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<CofreePartial<OptionPartial>>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<CofreePartial<OptionPartial>>.check()
    }
}
