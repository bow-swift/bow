import Foundation
import SwiftCheck
import Bow
import BowLaws
import BowEffects

public class BracketLaws<F: Bracket & EquatableK> where F.E: Equatable & Arbitrary & Error {

    public static func check() {
        bracketCaseWithJustUnitEqvMap()
        bracketCaseWithJustUnitIsUncancelable()
        bracketCaseFailureInAcquisitionRemainsFailure()
        bracketIsDerivedFromBracketCase()
        uncancelablePreventsCanceledCase()
        acquireAndReleaseAreUncancelable()
        guaranteeIsDerivedFromBracket()
        guaranteeCaseIsDerivedFromBracketCase()
        bracketPropagatesTransformerEffects()
        bracketMustRunReleaseTask()
        guaranteeMustRunFinalizerOnError()
    }

    private static func bracketCaseWithJustUnitEqvMap() {
        property("bracketCaseWithJustUnitEqvMap") <~ forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let fa = F.pure(a)
            return fa.bracketCase(release: constant(F.pure(())), use: { x in F.pure(f.getArrow(x)) }) == fa.map(f.getArrow)
        }
    }

    private static func bracketCaseWithJustUnitIsUncancelable() {
        property("bracketCaseWithJustUnitIsUncancelable") <~ forAll { (a: Int) in
            let fa = F.pure(a)
            return fa.bracketCase(release: constant(F.pure(())), use: F.pure) == fa.uncancelable().flatMap(F.pure)
        }
    }

    private static func bracketCaseFailureInAcquisitionRemainsFailure() {
        property("bracketCaseFailureInAcquisitionRemainsFailure") <~ forAll { (e: F.E) in
            let fe = Kind<F, Int>.raiseError(e)
            return fe.bracketCase(release: constant(F.pure(())), use: F.pure) == F.raiseError(e)
        }
    }

    private static func bracketIsDerivedFromBracketCase() {
        property("bracketIsDerivedFromBracketCase") <~ forAll { (a: Int) in
            let fa = F.pure(a)
            return fa.bracket(release: constant(F.pure(())), use: F.pure) == fa.bracketCase(release: constant(F.pure(())), use: F.pure)
        }
    }

    private static func uncancelablePreventsCanceledCase() {
        property("uncancelablePreventsCanceledCase") <~ forAll { (a: Int) in
            let fa = F.pure(a)
            let onCancel = F.pure(())
            let onFinish = F.pure(())
            return F.pure(()).bracketCase(release: { _, b in (b == ExitCase<F.E>.canceled) ? onCancel : onFinish}, use: { fa }).uncancelable() ==
                fa.guarantee(onFinish)
        }
    }

    private static func acquireAndReleaseAreUncancelable() {
        property("acquireAndReleaseAreUncancelable") <~ forAll { (a: Int) in
            let fa = F.pure(a)
            let release: (Int) -> Kind<F, ()> = constant(F.pure(()))
            return fa.uncancelable().bracket(release: { x in release(x).uncancelable() }, use: F.pure) == fa.bracket(release: release, use: F.pure)
        }
    }

    private static func guaranteeIsDerivedFromBracket() {
        property("guaranteeIsDerivedFromBracket") <~ forAll { (a: Int) in
            let fa = F.pure(a)
            let finalizer = F.pure(())
            return fa.guarantee(finalizer) == F.pure(()).bracket(release: { finalizer }, use: { fa })
        }
    }

    private static func guaranteeCaseIsDerivedFromBracketCase() {
        property("guaranteeCaseIsDerivedFromBracketCase") <~ forAll { (a: Int) in
            let fa = F.pure(a)
            let finalizer: (ExitCase<F.E>) -> Kind<F, ()> = constant(F.pure(()))
            return fa.guaranteeCase(finalizer) == F.pure(()).bracketCase(release: { _, e in finalizer(e) }, use: { fa })
        }
    }

    private static func bracketPropagatesTransformerEffects() {
        property("bracketPropagatesTransformerEffects") <~ forAll { (a: String, f: ArrowOf<String, Int>, g: ArrowOf<String, Int>) in
            let acquire = F.pure(a)
            let use = f.getArrow >>> F.pure
            let release = g.getArrow >>> { _ in F.pure(()) }
            return acquire.bracket(release: release, use: use) == acquire.flatMap { x in use(x).flatMap { y in release(x).map { y } } }
        }
    }

    private static func bracketMustRunReleaseTask() {
        property("bracketMustRunReleaseTask") <~ forAll { (a: Int, e: F.E) in
            var msg = 0
            return F.pure(a).bracket(release: { i in msg = i; return F.pure(()) }, use: { _ -> Kind<F, Int> in throw e })
                .attempt()
                .map { _ in msg } == F.pure(a)
        }
    }
    
    private static func guaranteeMustRunFinalizerOnError() {
        property("guaranteeMustRunReleaseOnError") <~ forAll { (a: Int, e: F.E) in
            var msg = 0
            let finalizer: Kind<F, ()> = F.pure(()).map { msg = a }
            return Kind<F, Int>.raiseError(e).guarantee(finalizer)
                .attempt()
                .map { _ in msg } == F.pure(a)
        }
    }
}
