import XCTest
import BowLaws
import Bow

extension SumPartial: EquatableK where F: Comonad, G: Comonad {
    public static func eq<A>(_ lhs: Kind<SumPartial<F, G>, A>, _ rhs: Kind<SumPartial<F, G>, A>) -> Bool where A : Equatable {
        return Sum.fix(lhs).extract() == Sum.fix(rhs).extract()
    }
}

class SumTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<SumPartial<ForId, ForId>>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<SumPartial<ForId, ForId>>.check()
    }
    
    let abSum = Sum.left(Id("A"), Id("B"))
    
    func testSumExtractReturnsViewOfCurrentSide() {
        XCTAssertEqual(self.abSum.extract(), "A")
        XCTAssertEqual(self.abSum.change(side: .right).extract(), "B")
    }
    
    func testCoflatMapTransformsViewType() {
        let firstCharacter = { (x : String) in x.first! }
        let result = abSum.coflatMap() { (sum) -> Character in
            let s = Sum.fix(sum)
            switch s.side {
            case .left: return firstCharacter(Id.fix(s.left).extract())
            case .right: return firstCharacter(Id.fix(s.right).extract())
            }
        }
        XCTAssertEqual(result.extract(), Character("A"))
    }
    
    func testMapTransformsViewType() {
        let firstCharacter = { (x : String) in x.first! }
        let result = abSum.map(firstCharacter)
        XCTAssertEqual(result.extract(), Character("A"))
    }
}
