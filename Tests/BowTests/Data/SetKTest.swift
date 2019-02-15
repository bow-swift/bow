import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class SetKTest: XCTestCase {

	var generator: (Int) -> SetK<Int> {
		return { a in SetK<Int>(Set([a])) }
	}

//    func testEquatableLaws() {
//        EquatableKLaws.check(generator: self.generator)
//    }
//
//    func testSemigroupLaws() {
//        property("SetK semigroup laws") <- forAll() { (a : Int, b : Int, c : Int) in
//            return SemigroupLaws<SetK<Int>>.check(
//                a: SetK<Int>(Set([a])),
//                b: SetK<Int>(Set([b])),
//                c: SetK<Int>(Set([c])))
//        }
//    }
//
//    func testMonoidLaws() {
//        property("SetK monoid laws") <- forAll() { (a : Int) in
//            return MonoidLaws<SetK<Int>>.check(a: SetK<Int>(Set([a])))
//        }
//    }
}
