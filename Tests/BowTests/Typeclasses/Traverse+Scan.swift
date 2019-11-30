import XCTest
import Bow

class TraverseScanTests: XCTestCase {
    func testArrayScan1() {
        let initialValue =  -1
        let input        = [-1,  0,  1, 2]
        let expected     = [-2, -2, -1, 1]
        XCTAssertEqual(expected, input.k().scanLeft(initialState: initialValue, f: +)^.asArray)
    }

    func testArrayScan2() {
        let initialValue = ""
        let input        = [-1,  0,  1, 2]
        let expected     = ["-1", "-10", "-101", "-1012"]
        XCTAssertEqual(expected, input.k().scanLeft(initialState: initialValue, f: { $0 + String($1) })^.asArray)
    }

    func testArrayScan3() {
        typealias S = (count: Int, previous: Int)

        // Number of negative values before current position
        let initialValue = (count: 0, previous: 0)
        let input    = [1, 2, -2, 3, -4, -4, 0, 1]
        let expected = [0, 0,  0, 1,  1,  2, 3, 3]

        let step: (Int) -> State<S, Int> = { value in

            let previousState = State<S, S>.var()
            let nextCount     = State<S, Int>.var()

            return binding(
                previousState <- StateTPartial<ForId, S>.get(),
                nextCount     <- StateTPartial<ForId, S>.pure(value < 0
                                                                ? previousState.get.count + 1
                                                                : previousState.get.count),
                              |<-StateTPartial<ForId, S>.set((count: nextCount.get, previous: value)),

                yield: previousState.get.count)^
        }

        XCTAssertEqual(expected, input.k().scanLeft(initialState: initialValue, f: step)^.asArray)
    }

    func testMonadicArrayScan1() {
        // This scan fails when the input has a 0
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

    func testMonadicArrayScan2() {
        // This scan fails when the input has a 0
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
