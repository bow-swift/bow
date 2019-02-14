import XCTest
import Nimble
import SwiftCheck
@testable import BowLaws
@testable import Bow

class EitherTest: XCTestCase {
    
    var generator : (Int) -> EitherOf<Int, Int> {
        return { a in Either.pure(a) }
    }

    func testEquatableLaws() {
        EquatableKLaws<EitherPartial<Int>, Int>.check(generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherPartial<Int>>.check(generator: self.generator)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<EitherPartial<Int>>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<EitherPartial<Int>>.check()
    }

    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<EitherPartial<CategoryError>>.check()
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<EitherPartial<CategoryError>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<EitherPartial<Int>>.check(generator: self.generator)
    }

    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws.check(generator: { (a: Int) in
            (a % 2 == 0) ?
                Either<Int, Int>.right(a) :
                Either<Int, Int>.left(a) })
    }
    
    func testFoldableLaws() {
        FoldableLaws<EitherPartial<Int>>.check(generator: self.generator)
    }
    
    func testTraverseLaws() {
        TraverseLaws<EitherPartial<Int>>.check(generator: self.generator)
    }
    
    func testCheckers() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        expect(left.isLeft).to(beTrue())
        expect(left.isRight).to(beFalse())
        expect(right.isLeft).to(beFalse())
        expect(right.isRight).to(beTrue())
    }
    
    func testSwap() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        expect(left.swap()).to(equal(Either<Int, String>.right("Hello")))
        expect(right.swap()).to(equal(Either<Int, String>.left(5)))
    }
    
    func testExists() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        let isPositive = { (x : Int) in x >= 0 }
        
        expect(left.exists(isPositive)).to(beFalse())
        expect(right.exists(isPositive)).to(beTrue())
        expect(right.exists(not <<< isPositive)).to(beFalse())
    }
    
    func testToOption() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)

        expect(left.toOption()).to(equal(Option<Int>.none()))
        expect(right.toOption()).to(equal(Option<Int>.some(5)))
    }
    
    func testGetOrElse() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        expect(left.getOrElse(10)).to(be(10))
        expect(right.getOrElse(10)).to(be(5))
    }
    
    func testFilterOrElse() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        let isPositive = { (x : Int) in x >= 0 }
        
        expect(left.filterOrElse(isPositive, "10")).to(equal(Either<String, Int>.left("Hello")))
        expect(right.filterOrElse(isPositive, "10")).to(equal(Either<String, Int>.right(5)))
        expect(right.filterOrElse(not <<< isPositive, "10")).to(equal(Either<String, Int>.left("10")))
    }
    
    func testConversionToString() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        expect(left.description).to(equal("Left(Hello)"))
        expect(right.description).to(equal("Right(5)"))
    }
}
