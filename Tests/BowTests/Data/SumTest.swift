import XCTest
import Nimble
@testable import Bow

class SumTest : XCTestCase {
    
    let cf = { (x : Int) in Sum.left(Id(x), Id(x)) }
    
    class SumEq : Eq {
        typealias A = SumOf<ForId, ForId, Int>
        
        func eqv(_ a: SumOf<ForId, ForId, Int>, _ b: SumOf<ForId, ForId, Int>) -> Bool {
            return Sum<ForId, ForId, Int>.fix(a).extract(Id<Int>.comonad(), Id<Int>.comonad()) ==
                Sum<ForId, ForId, Int>.fix(b).extract(Id<Int>.comonad(), Id<Int>.comonad())
        }
    }
    
    let abSum = Sum.left(Id("A"), Id("B"))
    
    func testSumExtractReturnsViewOfCurrentSide() {
        expect(self.abSum.extract(Id<String>.comonad(), Id<String>.comonad())).to(equal("A"))
        expect(self.abSum.change(side: .right).extract(Id<String>.comonad(), Id<String>.comonad())).to(equal("B"))
    }
    
    func testCoflatMapTransformsViewType() {
        let firstCharacter = { (x : String) in x.first! }
        let result = abSum.coflatMap(Id<String>.comonad(), Id<String>.comonad()) { (sum) -> Character in
            switch sum.side {
            case .left: return firstCharacter(sum.left.fix().extract())
            case .right: return firstCharacter(sum.right.fix().extract())
            }
        }
        expect(result.extract(Id<Character>.comonad(), Id<Character>.comonad())).to(equal(Character("A")))
    }
    
    func testMapTransformsViewType() {
        let firstCharacter = { (x : String) in x.first! }
        let result = abSum.map(Id<String>.functor(), Id<String>.functor(), firstCharacter)
        expect(result.extract(Id<Character>.comonad(), Id<Character>.comonad())).to(equal(Character("A")))
    }
}
