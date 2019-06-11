import XCTest
import SwiftCheck
@testable import BowLaws
import Bow

class WriterTTest: XCTestCase {
    var generator: (Int) -> WriterTOf<ForId, Int, Int> {
        return { a in WriterT.pure(a) }
    }

    func testEquatableLaws() {
        EquatableKLaws<WriterTPartial<ForId, Int>, Int>.check()
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
    
    func testSemigroupKLaws() {
        SemigroupKLaws<WriterTPartial<ForArrayK, Int>>.check(generator: { (a: Int) in WriterT.pure(a) })
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<WriterTPartial<ForArrayK, Int>>.check(generator: { (a: Int) in WriterT.pure(a) })
    }

    func testFunctorFilterLaws() {
        FunctorFilterLaws<WriterTPartial<ForOption, Int>>.check(generator: { (a : Int) in WriterT.pure(a) })
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<WriterTPartial<ForOption, Int>>.check(generator: { (a: Int) in WriterT.pure(a) })
    }
    
    func testMonadWriterLaws() {
        MonadWriterLaws<WriterTPartial<ForId, Int>>.check()
    }
}
