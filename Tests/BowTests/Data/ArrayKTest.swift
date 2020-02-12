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

    func testScan1() {
        let initialValue =  -1
        let input        = [-1,  0,  1, 2]
        let expected     = [-2, -2, -1, 1]
        XCTAssertEqual(expected, input.k().scanLeft(initialState: initialValue, f: +)^.asArray)
    }

    func testScan2() {
        let initialValue = ""
        let input        = [-1,  0,  1, 2]
        let expected     = ["-1", "-10", "-101", "-1012"]
        XCTAssertEqual(expected, input.k().scanLeft(initialState: initialValue, f: { $0 + String($1) })^.asArray)
    }

    func testScan3() {
        typealias S = (count: Int, previous: Int)

        // Number of negative values before current position
        let initialValue = (count: 0, previous: 0)
        let input    = [1, 2, -2, 3, -4, -4, 0, 1]
        let expected = [0, 0,  0, 1,  1,  2, 3, 3]

        let step: (Int) -> State<S, Int> = { value in

            let previousState = State<S, S>.var()
            let nextCount     = State<S, Int>.var()

            return binding(
                previousState <-- StateTPartial<ForId, S>.get(),
                nextCount     <-- StateTPartial<ForId, S>.pure(value < 0
                                                                ? previousState.get.count + 1
                                                                : previousState.get.count),
                              |<-StateTPartial<ForId, S>.set((count: nextCount.get, previous: value)),

                yield: previousState.get.count)^
        }

        XCTAssertEqual(expected, input.k().scanLeft(initialState: initialValue, f: step)^.asArray)
    }

    func testMonadicScan1() {
        // This scan should fail when the input has a 0
        let initialValue = Option<Int>.pure(0)
        let input            = [1, 2,  2, 3, -4, -4, 0, 1]
        let expected: [Int]? = nil

        let step: (Int, Int) -> Option<Int> = { state, value in
            if value == 0 {
                return .none()
            }
            return .some(state / value)
        }

        let result = input.k().scanLeftM(initialState: initialValue, f: step)^
            .toOptional().map { $0^.asArray }

        XCTAssertEqual(expected, result)
    }

    func testMonadicScan2() {
        // This scan should fail when the input has a 0
        let initialValue = Option<Int>.pure(10)
        let input            = [1,  2, 2, 3, 4, 4, 1, 1]
        let expected: [Int]? = [10, 5, 2, 0, 0, 0, 0, 0]

        let step: (Int, Int) -> Option<Int> = { state, value in
            if value == 0 {
                return .none()
            }
            return .some(state / value)
        }

        let result = input.k().scanLeftM(initialState: initialValue, f: step)^
            .toOptional().map { $0^.asArray }

        XCTAssertEqual(expected, result)
    }
}
