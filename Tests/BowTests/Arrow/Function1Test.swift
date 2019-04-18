import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

extension Function1Partial: EquatableK where I == Int {
    public static func eq<A>(_ lhs: Kind<Function1Partial<I>, A>, _ rhs: Kind<Function1Partial<I>, A>) -> Bool where A : Equatable {
        return Function1.fix(lhs).invoke(1) == Function1.fix(rhs).invoke(1)
    }
}

class Function1Test: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<Function1Partial<Int>>.check(generator: { a in Function1<Int, Int>.pure(a) })
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<Function1Partial<Int>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<Function1Partial<Int>>.check()
    }

    func testMonadLaws() {
        MonadLaws<Function1Partial<Int>>.check()
    }

    func testSemigroupLaws() {
        func testSemigroupLaws() {
            property("Function1 semigroup laws") <- forAll() { (f: ArrowOf<Int, Int>, g: ArrowOf<Int, Int>, h: ArrowOf<Int, Int>) in
                return SemigroupLaws<Function1<Int, Int>>.check(
                    a: Function1(f.getArrow),
                    b: Function1(g.getArrow),
                    c: Function1(h.getArrow))
            }
        }
    }
}
