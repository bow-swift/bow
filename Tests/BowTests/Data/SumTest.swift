import XCTest
import Nimble
@testable import BowLaws
import Bow

extension SumPartial: EquatableK where F: Comonad, G: Comonad {
    public static func eq<A>(_ lhs: Kind<SumPartial<F, G>, A>, _ rhs: Kind<SumPartial<F, G>, A>) -> Bool where A : Equatable {
        return Sum.fix(lhs).extract() == Sum.fix(rhs).extract()
    }
}

class SumTest: XCTestCase {
    let generator = { (x: Int) in Sum.left(Id(x), Id(x)) }
    
    func testFunctorLaws() {
        FunctorLaws<SumPartial<ForId, ForId>>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<SumPartial<ForId, ForId>>.check()
    }
    
    let abSum = Sum.left(Id("A"), Id("B"))
    
    func testSumExtractReturnsViewOfCurrentSide() {
        expect(self.abSum.extract()).to(equal("A"))
        expect(self.abSum.change(side: .right).extract()).to(equal("B"))
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
        expect(result.extract()).to(equal(Character("A")))
    }
    
    func testMapTransformsViewType() {
        let firstCharacter = { (x : String) in x.first! }
        let result = abSum.map(firstCharacter)
        expect(result.extract()).to(equal(Character("A")))
    }
}
