import XCTest
import SwiftCheck
import BowLaws
import Bow

class ZipperTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<ForZipper, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForZipper>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<ForZipper>.check()
    }
    
    let nonEmptyArrayGen = [Int].arbitrary.suchThat { x in x.count > 0 }
    func testToArray() {
        property("From/To Array isomorphism") <~ forAll(self.nonEmptyArrayGen) { (array: [Int]) in
            let zipper = Zipper(fromArray: array)!
            return array == zipper.asArray()
        }
    }
    
    func testMoveLeft() {
        let zipper = Zipper(left: [1, 2, 3], focus: 4, right: [5, 6])
        let moved = zipper.moveLeft()
        let expected = Zipper(left: [1, 2], focus: 3, right: [4, 5, 6])
        XCTAssertEqual(moved, expected, "Focus should be 3")
    }
    
    func testMoveRight() {
        let zipper = Zipper(left: [1, 2, 3], focus: 4, right: [5, 6])
        let moved = zipper.moveRight()
        let expected = Zipper(left: [1, 2, 3, 4], focus: 5, right: [6])
        XCTAssertEqual(moved, expected, "Focus should be 5")
    }
    
    func testCoflatMap() {
        let zipper = Zipper(left: [1, 2, 3], focus: 4, right: [5, 6])
        // f computes each element plus its neighbors
        let f = { (zipper: ZipperOf<Int>) -> Int in
            zipper.extract()
                + (zipper^.moveLeft()?.extract() ?? 0)
                + (zipper^.moveRight()?.extract() ?? 0)
        }
        let expected = Zipper(left: [3, 6, 9], focus: 12, right: [15, 11])
        let result = zipper.coflatMap(f)
        XCTAssertEqual(result, expected)
    }
}
