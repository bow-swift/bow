import XCTest
import Nimble
@testable import Bow

class DayTest : XCTestCase {
    let cf = { (x : Int) in Day.from(left: Id(x), right: Id(0), f: +) }
    
    class DayEq : Eq {
        typealias A = DayOf<ForId, ForId, Int>
        
        func eqv(_ a: DayOf<ForId, ForId, Int>, _ b: DayOf<ForId, ForId, Int>) -> Bool {
            return Day<ForId, ForId, Int>.fix(a).extract(Id<Int>.comonad(), Id<Int>.comonad()) ==
                Day<ForId, ForId, Int>.fix(b).extract(Id<Int>.comonad(), Id<Int>.comonad())
        }
    }
    
    class DayEqUnit : Eq {
        typealias A = DayOf<ForId, ForId, ()>
        
        func eqv(_ a: DayOf<ForId, ForId, ()>, _ b: DayOf<ForId, ForId, ()>) -> Bool {
            return Day<ForId, ForId, ()>.fix(a).extract(Id<Int>.comonad(), Id<()>.comonad()) ==
                Day<ForId, ForId, ()>.fix(b).extract(Id<Int>.comonad(), Id<()>.comonad())
        }
    }
    
    func testFunctorLaws() {
        FunctorLaws.check(functor: Day<ForId, ForId, Int>.functor(), generator: cf, eq: DayEq(), eqUnit: DayEqUnit())
    }
    
    func testComonadLaws() {
        ComonadLaws.check(comonad: Day<ForId, ForId, Int>.comonad(Id<Int>.comonad(), Id<Int>.comonad()), generator: cf, eq: DayEq())
    }
    
    let day = Day.from(left: Id(1), right: Id(1), f: { (left : Int, right : Int) in (left, right) })
    let compareSides = { (left : Int, right : Int) -> String in
        if left > right {
            return "Left is greater"
        } else if right > left {
            return "Right is greater"
        } else {
            return "Both sides are equal"
        }
    }
    
    func testDayExtract() {
        let result = day.extract(Id<Int>.comonad(), Id<Int>.comonad())
        expect(result.0).to(equal(1))
        expect(result.1).to(equal(1))
    }
    
    func testDayCoflatMap() {
        let transformed = day.coflatMap(Id<Int>.comonad(), Id<Int>.comonad()) { (x : DayOf<ForId, ForId, (Int, Int)>) -> String  in
            let result = Day<ForId, ForId, (Int, Int)>.fix(x).extract(Id<Int>.comonad(), Id<Int>.comonad())
            return self.compareSides(result.0, result.1)
        }
        expect(transformed.extract(Id<String>.comonad(), Id<String>.comonad())).to(equal("Both sides are equal"))
    }
    
    func testDayMap() {
        let mapped = day.map { x in self.compareSides(x.0, x.1) }
        expect(mapped.extract(Id<String>.comonad(), Id<String>.comonad())).to(equal("Both sides are equal"))
    }
}
