import XCTest
import SwiftCheck
import BowLaws
import Bow

class ArrayKTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<ForArrayK, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForArrayK>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForArrayK>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ForArrayK>.check()
    }

    func testMonadLaws() {
        MonadLaws<ForArrayK>.check()
    }
    
    func testSemigroupLaws() {
        SemigroupLaws<ArrayK<Int>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<ForArrayK>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<ArrayK<Int>>.check()
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<ForArrayK>.check()
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<ForArrayK>.check()
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<ForArrayK>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForArrayK>.check()
    }
    
    func testMonadCombineLaws() {
        MonadCombineLaws<ForArrayK>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForArrayK>.check()
    }
    
    func testMonadComprehensions() {
        property("Monad comprehensions for ArrayK") <~ forAll { (a: ArrayK<Int>, b: ArrayK<Double>, c: ArrayK<String>) in
            let r1 = a.flatMap { x in b.flatMap { y in c.map { z in "\(x), \(y), \(z)" } } }^
            
            let x = ArrayK<Int>.var()
            let y = ArrayK<Double>.var()
            let z = ArrayK<String>.var()
            
            let r2 = binding(
                x <-- a,
                y <-- b,
                z <-- c,
                yield: "\(x.get), \(y.get), \(z.get)"
            )^
            
            return r1 == r2
        }
    }
}
