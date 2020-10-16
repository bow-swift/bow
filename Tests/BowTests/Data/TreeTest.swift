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

    func testFoldableIsDepthFirst() {
        //      0
        //    /   \
        //   1     3
        //  /
        // 2
        let tree = Tree(root: 0, subForest: [Tree(root: 1, subForest: [Tree(root: 2, subForest: [])]), Tree(root: 3, subForest: [])])
        XCTAssertEqual(tree.foldMap { ArrayK($0).asArray }, [0, 1, 2, 3])
    }

    func testTraverseLaws() {
        TraverseLaws<TreePartial>.check()
    }
}
