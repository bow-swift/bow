import XCTest
import SwiftCheck
@testable import BowLaws
import Bow

extension Function1LazyCompositionPartial: EquatableK where I == Int {
    public static func eq<A>(_ lhs: Kind<Function1LazyCompositionPartial<I>, A>, _ rhs: Kind<Function1LazyCompositionPartial<I>, A>) -> Bool where A : Equatable {
        Function1LazyComposition.fix(lhs).run(1)
            ==
        Function1LazyComposition.fix(rhs).run(1)
    }
}

extension Function1LazyComposition: Semigroup where I == O {
    public func combine(_ other: Function1LazyComposition) -> Function1LazyComposition {
        andThen(other)
    }
}

class Function1LazyCompositionTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<Function1LazyCompositionPartial<Int>>.check()
    }

    func testEquivalenceToFunction1() {
        property("Function1LazyComposition gives the same result than Function1") <~ forAll() { (i: Int, f: ArrowOf<Int, String>, g: ArrowOf<String, Int>) in
            (g.getArrow <<< f.getArrow)(i)
                ==
            Function1LazyComposition(f.getArrow).andThen(Function1LazyComposition(g.getArrow)).run(i)
        }
    }

    func testStackSafety() {
        let iterations = 200000
        let sum: Function1LazyComposition<Int, Int> = Function1LazyComposition({ $0 + 1 })
        let f = Function1LazyComposition.combineAll(sum, Array(repeating: sum, count: iterations - 1))

        XCTAssertEqual(f.run(0), iterations)
    }
}
