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
    func testCofreeOptionIsNEA() {
        func toNEA(cofree: Cofree<OptionPartial, Int>) -> NEA<Int> {
            let a = cofree.head
            if let next = cofree.tailForced()^.toOptional() {
                return NEA.of(a) + toNEA(cofree: next)
            } else {
                return NEA.of(a)
            }
        }
        
        let nea = Cofree<OptionPartial, Int>.create(1) { x in
            x < 5
                ? Option.some(x + 1)
                : Option.none()
        }
        let mapped = nea.map { x in 2 * x }^
        let result = toNEA(cofree: mapped)
        let expected = NEA.of(2, 4, 6, 8, 10)
        XCTAssertEqual(result, expected)
    }
    
    func testFunctorLaws() {
        FunctorLaws<CofreePartial<OptionPartial>>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<CofreePartial<OptionPartial>>.check()
    }
}
