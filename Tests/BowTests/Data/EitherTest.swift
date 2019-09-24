import XCTest
@testable import BowLaws
import Bow

class EitherTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<EitherPartial<Int>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherPartial<Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<EitherPartial<Int>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<EitherPartial<Int>>.check()
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
        SemigroupKLaws<EitherPartial<Int>>.check()
    }

    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Either<Int, Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<EitherPartial<Int>>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<EitherPartial<Int>>.check()
    }
    
    func testSemigroupLaws() {
        SemigroupLaws<Either<Int, Int>>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<Either<Int, Int>>.check()
    }
    
    func testCheckers() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        XCTAssertTrue(left.isLeft)
        XCTAssertFalse(left.isRight)
        XCTAssertFalse(right.isLeft)
        XCTAssertTrue(right.isRight)
    }
    
    func testSwap() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        XCTAssertEqual(left.swap(), Either<Int, String>.right("Hello"))
        XCTAssertEqual(right.swap(), Either<Int, String>.left(5))
    }
    
    func testExists() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        let isPositive = { (x : Int) in x >= 0 }
        
        XCTAssertFalse(left.exists(isPositive))
        XCTAssertTrue(right.exists(isPositive))
        XCTAssertFalse(right.exists(not <<< isPositive))
    }
    
    func testToOption() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)

        XCTAssertEqual(left.toOption(), Option<Int>.none())
        XCTAssertEqual(right.toOption(), Option<Int>.some(5))
    }
    
    func testGetOrElse() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        XCTAssertEqual(left.getOrElse(10), 10)
        XCTAssertEqual(right.getOrElse(10), 5)
    }
    
    func testFilterOrElse() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        let isPositive = { (x : Int) in x >= 0 }
        
        XCTAssertEqual(left.filterOrElse(isPositive, "10"), Either<String, Int>.left("Hello"))
        XCTAssertEqual(right.filterOrElse(isPositive, "10"), Either<String, Int>.right(5))
        XCTAssertEqual(right.filterOrElse(not <<< isPositive, "10"), Either<String, Int>.left("10"))
    }
    
    func testConversionToString() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        XCTAssertEqual(left.description, "Left(Hello)")
        XCTAssertEqual(right.description, "Right(5)")
    }
}
