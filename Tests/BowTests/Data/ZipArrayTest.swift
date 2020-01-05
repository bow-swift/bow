import XCTest
import SwiftCheck
import BowLaws
import Bow

class ZipArrayTest: XCTestCase {
    func testEquatableKLaws() {
        EquatableKLaws<ForZipArray, Int>.check()
    }

    func testSemiGroupKLaws() {
        SemigroupKLaws<ForZipArray>.check()
    }

    func testMonoidKLaws() {
        MonoidKLaws<ForZipArray>.check()
    }

    func testFunctorLaws() {
        FunctorLaws<ForZipArray>.check()
    }

    func testApplicativeLaws() {
        ApplicativeLaws<ForZipArray>.check()
    }

}
