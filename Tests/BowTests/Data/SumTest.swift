import XCTest
import Nimble
@testable import BowLaws
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
    
    class SumEqUnit : Eq {
        typealias A = SumOf<ForId, ForId, ()>
        
        func eqv(_ a: SumOf<ForId, ForId, ()>, _ b: SumOf<ForId, ForId, ()>) -> Bool {
            return Sum<ForId, ForId, ()>.fix(a).extract(Id<()>.comonad(), Id<()>.comonad()) ==
                Sum<ForId, ForId, ()>.fix(b).extract(Id<()>.comonad(), Id<()>.comonad())
        }
    }
    
    func testFunctorLaws() {
        FunctorLaws.check(functor: Sum<ForId, ForId, Int>.functor(Id<Int>.functor(), Id<Int>.functor()), generator: cf, eq: SumEq(), eqUnit: SumEqUnit())
    }
    
    func testComonadLaws() {
        ComonadLaws.check(comonad: Sum<ForId, ForId, Int>.comonad(Id<Int>.comonad(), Id<Int>.comonad()), generator: cf, eq: SumEq())
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
            case .left: return firstCharacter(Id<String>.fix(sum.left).extract())
            case .right: return firstCharacter(Id<String>.fix(sum.right).extract())
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
