import XCTest
import SwiftCheck
@testable import BowLaws
import Bow

class IorTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<IorPartial<Int>, Int>.check()
    }

    func testHashableKLaws() {
        HashableKLaws<IorPartial<Int>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<IorPartial<Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<IorPartial<Int>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<IorPartial<Int>>.check()
    }

    func testMonadLaws() {
        MonadLaws<IorPartial<Int>>.check()
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Ior<Int, Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<IorPartial<Int>>.check()
    }
    
    func testCheckers() {
        property("Ior can only be one of left, right or both") <~ forAll { (input: Ior<Int, Int>) in
            return xor(input.isBoth, xor(input.isLeft, input.isRight))
        }
    }
    
    func testBimapConsistent() {
        property("bimap is equivalent to map and mapLeft") <~ forAll { (input: Ior<Int, Int>, f: ArrowOf<Int, Int>, g: ArrowOf<Int, Int>) in
            return input.bimap(f.getArrow, g.getArrow) == Ior.fix(input.map(g.getArrow)).mapLeft(f.getArrow)
        }
    }
    
    func testSwapIsomorphism() {
        property("swap twice is equivalent to identity") <~ forAll { (input: Ior<Int, Int>) in
            return input.swap().swap() == input
        }
    }
    
    func testToEither() {
        property("left and right preserved in conversion to Either") <~ forAll { (input: Ior<Int, Int>) in
            return (input.isLeft && input.toEither().isLeft) || input.toEither().isRight
        }
    }
    
    func testToOption() {
        property("right or both converted to some") <~ forAll { (input: Ior<Int, Int>) in
            return (input.isLeft && input.toOption().isEmpty) || input.toOption().isDefined
        }
    }
}
