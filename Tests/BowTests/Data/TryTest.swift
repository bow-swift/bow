import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class TryTest: XCTestCase {
    
    var generator : (Int) -> Try<Int> {
        return { a in (a % 2 == 0) ? Try.invoke(constant(a)) : Try.invoke({ throw TryError.illegalState }) }
    }

    func testEquatableLaws() {
        EquatableKLaws.check(generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForTry>.check(generator: self.generator)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForTry>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ForTry>.check()
    }

    func testMonadLaws() {
        MonadLaws<ForTry>.check()
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws.check(generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForTry>.check(generator: self.generator)
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForTry>.check(generator: self.generator)
    }

    func testFunctorFilterLaws() {
        FunctorFilterLaws<ForTry>.check(generator: self.generator)
    }

    func testSemigroupLaws() {
        property("Try semigroup laws") <- forAll { (a: Int, b: Int, c: Int) in
            return SemigroupLaws<Try<Int>>.check(
                a: Try.success(a),
                b: Try.success(b),
                c: Try.success(c))
        }
    }

    func testMonoidLaws() {
        property("Try monoid laws") <- forAll { (a: Int) in
            return MonoidLaws<Try<Int>>.check(a: Try.success(a))
        }
    }
}
