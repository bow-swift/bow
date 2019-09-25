import Foundation
import SwiftCheck
import Bow
import BowEffects
import BowLaws
import XCTest

public class MonadDeferLaws<F: MonadDefer & EquatableK> where F.E: Arbitrary & Equatable & Error {

    public static func check() {
        delayConstantEqualsPure()
        deferConstantEqualsPure()
        delayOrRaiseConstantRightEqualsPure()
        delayOrRaiseConstantLeftEqualsRaiseError()
        delayThrowEqualsRaiseError()
        propagateErrorsThroughBind()
        deferSuspendsEvaluation()
        delaySuspendsEvaluation()
        flatMapSuspendsEvaluation()
        mapSuspendsEvaluation()
        repeatedSyncEvaluationNotMemoized()
    }

    private static func delayConstantEqualsPure() {
        property("delayConstantEqualsPure") <~ forAll { (x: Int) in
            return F.later { x } == F.pure(x)
        }
    }

    private static func deferConstantEqualsPure() {
        property("deferConstantEqualsPure") <~ forAll { (x: Int) in
            return F.defer { F.pure(x) } == F.pure(x)
        }
    }

    private static func delayOrRaiseConstantRightEqualsPure() {
        property("delayOrRaiseConstantRightEqualsPure") <~ forAll { (x: Int) in
            return F.laterOrRaise { .right(x) } == F.pure(x)
        }
    }

    private static func delayOrRaiseConstantLeftEqualsRaiseError() {
        property("delayOrRaiseConstantLeftEqualsRaiseError") <~ forAll { (e: F.E) in
            return F.laterOrRaise { .left(e) } == Kind<F, Int>.raiseError(e)
        }
    }

    private static func delayThrowEqualsRaiseError() {
        property("delayThrowEqualsRaiseError") <~ forAll { (e: F.E) in
            return F.later { throw e } == Kind<F, Int>.raiseError(e)
        }
    }

    private static func propagateErrorsThroughBind() {
        property("propagateErrorsThroughBind") <~ forAll { (e: F.E) in
            return F.later { throw e }.flatMap(F.pure) == Kind<F, Int>.raiseError(e)
        }
    }

    private static func deferSuspendsEvaluation() {
        let sideEffect = SideEffect()
        let df = F.defer { () -> Kind<F, Int> in sideEffect.increment(); return F.pure(sideEffect.counter) }

        XCTAssertEqual(sideEffect.counter, 0)
        XCTAssertEqual(df, F.pure(1))
    }

    private static func delaySuspendsEvaluation() {
        let sideEffect = SideEffect()
        let df = F.later { () -> Int in sideEffect.increment(); return sideEffect.counter }

        XCTAssertEqual(sideEffect.counter, 0)
        XCTAssertEqual(df, F.pure(1))
    }

    private static func flatMapSuspendsEvaluation() {
        let sideEffect = SideEffect()
        let df = F.pure(0).flatMap { _ -> Kind<F, Int> in sideEffect.increment(); return F.pure(sideEffect.counter) }

        XCTAssertEqual(sideEffect.counter, 0)
        XCTAssertEqual(df, F.pure(1))
    }

    private static func mapSuspendsEvaluation() {
        let sideEffect = SideEffect()
        let df = F.pure(0).map { _ -> Int in sideEffect.increment(); return sideEffect.counter }

        XCTAssertEqual(sideEffect.counter, 0)
        XCTAssertEqual(df, F.pure(1))
    }

    private static func repeatedSyncEvaluationNotMemoized() {
        let sideEffect = SideEffect()
        let df = F.later { () -> Int in sideEffect.increment(); return sideEffect.counter }

        XCTAssertEqual(df.flatMap { _ in df }.flatMap { _ in df }, F.pure(3))
    }
}

private class SideEffect {
    private(set) var counter: Int = 0

    func increment() {
        counter += 1
    }
}
