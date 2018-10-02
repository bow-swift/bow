import XCTest
import Nimble
import SwiftCheck
@testable import Bow

class IorTest: XCTestCase {
    var generator = { (a : Int) -> Ior<Int, Int> in
        switch a % 3 {
        case 0 : return Ior.left(a)
        case 1: return Ior.right(a)
        default: return Ior.both(a, a)
        }
    }
    
    let eq = Ior.eq(Int.order, Int.order)
    let eqUnit = Ior.eq(Int.order, UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<IorPartial<Int>>.check(functor: Ior<Int, Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<IorPartial<Int>>.check(applicative: Ior<Int, Int>.applicative(Int.sumMonoid), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<IorPartial<Int>>.check(monad: Ior<Int, Int>.monad(Int.sumMonoid), eq: self.eq)
    }
    
    func testShowLaws() {
        ShowLaws.check(show: Ior.show(), generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<IorPartial<Int>>.check(foldable: Ior<Int, Int>.foldable(), generator: self.generator)
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
            return self.eq.eqv(input.bimap(f.getArrow, g.getArrow),
                               input.map(g.getArrow).mapLeft(f.getArrow))
        }
    }
    
    func testSwapIsomorphism() {
        property("swap twice is equivalent to identity") <- forAll { (x : Int) in
            let input = self.generator(x)
            return self.eq.eqv(input.swap().swap(),
                               input)
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
