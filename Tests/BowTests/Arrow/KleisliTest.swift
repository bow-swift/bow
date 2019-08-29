import XCTest
@testable import BowLaws
import Bow
import SwiftCheck

class KleisliTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<KleisliPartial<ForId, Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<KleisliPartial<ForId, Int>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<KleisliPartial<ForId, Int>>.check()
    }

    func testMonadLaws() {
        MonadLaws<KleisliPartial<ForId, Int>>.check()
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<KleisliPartial<EitherPartial<CategoryError>, Int>>.check()
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<KleisliPartial<EitherPartial<CategoryError>, Int>>.check()
    }
    
    func testReaderComprehension() {
        property("Monad comprehensions with MonadReader utilities") <~ forAll { (v1: Int, v2: Int) in
            let a = KleisliPartial<ForId, Int>.var(Int.self)
            
            let x = binding(
                |<-askReader(),
                localReader { x in 2 * x },
                a <-- KleisliPartial<ForId, Int>.pure(v1),
                yield: a.get)^.invoke(v2)^.value
            
            let y = KleisliPartial<ForId, Int>.ask()
                .local { x in 2 * x }
                .flatMap { _ in KleisliPartial<ForId, Int>.pure(v1) }^
                .invoke(v2)^.value
            
            return x == y
        }
    }
}
