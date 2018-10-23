import XCTest
import SwiftCheck
@testable import Bow

class MemoizationTest: XCTestCase {

    let positiveInts = Int.arbitrary.suchThat { x in x > 0 }
    
    func testMemoizedFunctionCachesResults() {
        var timesCalled = 0
        func longRunningOperation(_ x : Int) -> Int {
            timesCalled += 1
            return x + 1
        }
        
        property("Memoized function is only called once for the same input") <- forAll(Int.arbitrary, self.positiveInts) { (input : Int, times : Int) in
            timesCalled = 0
            let memoizedFunction = memoize(longRunningOperation)
            
            for _ in 0 ..< times {
                let _ = memoizedFunction(input)
            }
            
            return timesCalled == 1
        }
    }
    
    let smallInts = Int.arbitrary.suchThat { x in x > 0 && x < 20 }
    
    func testMemoizedRecursiveFunctionCachesResult() {
        property("Memoized function is only called once for the same input") <- forAll(self.smallInts, self.positiveInts) { (input : Int, times : Int) in
            var timesCalled = Dictionary<Int, Int>()
            timesCalled[input] = 0
            
            let memoizedFactorial : (Int) -> Int = memoize { factorial, x in
                timesCalled[x] = (timesCalled[x] ?? 0) + 1
                return x == 0 ? 1 : x * factorial(x - 1)
            }
            
            for _ in 0 ..< times {
                let _ = memoizedFactorial(input)
            }
            
            return timesCalled[input] == 1
        }
    }

}
