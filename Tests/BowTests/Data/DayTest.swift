import XCTest
import BowLaws
import Bow

extension DayPartial: EquatableK where F == ForId, G == ForId {
    public static func eq<A: Equatable>(_ lhs: DayOf<F, G, A>,
                                        _ rhs: DayOf<F, G, A>) -> Bool {
        Day.fix(lhs).extract() == Day.fix(rhs).extract()
    }
}

class DayTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<DayPartial<ForId, ForId>>.check()
    }

    func testApplicativeLaws() {
        ApplicativeLaws<DayPartial<ForId, ForId>>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<DayPartial<ForId, ForId>>.check()
    }

    let day = Day<ForId, ForId, (Int, Int)>(
        left: Id(1),
        right: Id(1)) { left, right in
            (left, right)
        }
    
    let compareSides = { (left: Int, right: Int) -> String in
        if left > right {
            return "Left is greater"
        } else if right > left {
            return "Right is greater"
        } else {
            return "Both sides are equal"
        }
    }

    func testDayExtract() {
        let result = day.extract()
        
        XCTAssertEqual(result.0, 1)
        XCTAssertEqual(result.1, 1)
    }

    func testDayCoflatMap() {
        let transformed = day.coflatMap() { (x : DayOf<ForId, ForId, (Int, Int)>) -> String  in
            let result = Day.fix(x).extract()
            return self.compareSides(result.0, result.1)
        }
        
        XCTAssertEqual(transformed.extract(), "Both sides are equal")
    }

    func testDayMap() {
        let mapped = day.map { x in self.compareSides(x.0, x.1) }
        XCTAssertEqual(mapped.extract(), "Both sides are equal")
    }
}
