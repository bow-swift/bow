import XCTest
@testable import BowLaws
import Bow

class WriterTTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<WriterTPartial<ForId, Int>, Int>.check()
    }

    func testHashableLaws() {
        HashableKLaws<WriterTPartial<ForId, Int>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<WriterTPartial<ForId, Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<WriterTPartial<ForId, Int>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<WriterTPartial<ForId, Int>>.check()
    }

    func testMonadLaws() {
        MonadLaws<WriterTPartial<ForId, Int>>.check()
    }

    func testMonadTransLaws() {
        MonadTransLaws<WriterTPartial<ForId, Int>, String, Int>.check()
        MonadTransLaws<WriterTPartial<ForOption, Int>, String, Int>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<WriterTPartial<ForArrayK, Int>>.check()
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<WriterTPartial<ForArrayK, Int>>.check()
    }

    func testFunctorFilterLaws() {
        FunctorFilterLaws<WriterTPartial<ForOption, Int>>.check()
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<WriterTPartial<ForOption, Int>>.check()
    }
    
    func testMonadWriterLaws() {
        MonadWriterLaws<WriterTPartial<ForId, Int>>.check()
    }
    
    func testMonadStateLaws() {
        MonadStateLaws<WriterTPartial<StatePartial<Int>, Int>>.check()
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<WriterTPartial<EitherPartial<CategoryError>, Int>>.check()
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<WriterTPartial<EitherPartial<CategoryError>, Int>>.check()
    }
    
    func testCensor() {
        let x = Writer.writer(("A", 1))
        let result = x.censor { x in x.lowercased() }
        let expected = Writer.writer(("a", 1))
        
        print(result^.run)
        print(expected^.run)
        
        XCTAssertEqual(result, expected)
    }
}
