import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class SetKTest: XCTestCase {

	var generator : (Int) -> SetKOf<Int> {
		return { a in SetK<Int>.pure(a) }
	}

	let eq = SetK.eq(IntEq())

	func testEqLaws() {
		EqLaws.check(eq: self.eq, generator: self.generator)
	}

	func testSemigroupLaws() {
		property("SetK semigroup laws") <- forAll() { (a : Int, b : Int, c : Int) in

			print(a,b,c)
			return SemigroupLaws<SetKOf<Int>>.check(
				semigroup: SetK<Int>.semigroup(),
				a: SetK<Int>.pure(a),
				b: SetK<Int>.pure(b),
				c: SetK<Int>.pure(c),
				eq: self.eq)
		}
	}

	func testMonoidLaws() {
		property("SetK monoid laws") <- forAll() { (a : Int) in
			return MonoidLaws<SetKOf<Int>>.check(monoid: SetK<Int>.monoid(), a: SetK<Int>.pure(a), eq: self.eq)
		}
	}
}
