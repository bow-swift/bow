import XCTest
import SwiftCheck
import BowLaws
import Bow


@testable import BowGenerators

class TreeTest: XCTestCase {

    func testEquatableLaws() {
        EquatableKLaws<TreePartial, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<TreePartial>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<TreePartial>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<TreePartial>.check()
    }

    func testMonadLaws() {
        MonadLaws<TreePartial>.check()
    }

    func testFoldableLaws() {
        FoldableLaws<TreePartial>.check()
    }

    func testTraverseLaws() {
        TraverseLaws<TreePartial>.check()
    }
}
