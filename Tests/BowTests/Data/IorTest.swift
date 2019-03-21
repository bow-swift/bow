import XCTest
import Nimble
import SwiftCheck
@testable import BowLaws
@testable import Bow

class IorTest: XCTestCase {
    var generator = { (a : Int) -> Ior<Int, Int> in
        switch a % 3 {
        case 0 : return Ior.left(a)
        case 1: return Ior.right(a)
        default: return Ior.both(a, a)
        }
    }

    func testEquatableLaws() {
        EquatableKLaws.check(generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<IorPartial<Int>>.check(generator: self.generator)
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
        CustomStringConvertibleLaws.check(generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<IorPartial<Int>>.check(generator: self.generator)
    }
    
    func testCheckers() {
        property("Ior can only be one of left, right or both") <- forAll { (x : Int) in
            let input = self.generator(x)
            return xor(input.isBoth, xor(input.isLeft, input.isRight))
        }
    }
    
    func testBimapConsitent() {
        property("bimap is equivalent to map and mapLeft") <- forAll { (x : Int, f : ArrowOf<Int, Int>, g : ArrowOf<Int, Int>) in
            let input = self.generator(x)
            return input.bimap(f.getArrow, g.getArrow) == Ior.fix(input.map(g.getArrow)).mapLeft(f.getArrow)
        }
    }
    
    func testSwapIsomorphism() {
        property("swap twice is equivalent to identity") <- forAll { (x : Int) in
            let input = self.generator(x)
            return input.swap().swap() == input
        }
    }
    
    func testToEither() {
        property("left and right preserved in conversion to Either") <- forAll { (x : Int) in
            let input = self.generator(x)
            return (input.isLeft && input.toEither().isLeft) || input.toEither().isRight
        }
    }
    
    func testToOption() {
        property("right or both converted to some") <- forAll { (x : Int) in
            let input = self.generator(x)
            return (input.isLeft && input.toOption().isEmpty) || input.toOption().isDefined
        }
    }
}
