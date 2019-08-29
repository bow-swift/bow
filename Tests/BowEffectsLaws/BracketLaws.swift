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
    }

    private static func bracketCaseWithJustUnitEqvMap() {
        property("bracketCaseWithJustUnitEqvMap") <~ forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let fa = F.pure(a)
            return fa.bracketCase(constant(F.pure(())), { x in F.pure(f.getArrow(x)) }) == fa.map(f.getArrow)
        }
    }

    private static func bracketCaseWithJustUnitIsUncancelable() {
        property("bracketCaseWithJustUnitIsUncancelable") <~ forAll { (a: Int) in
            let fa = F.pure(a)
            return fa.bracketCase(constant(F.pure(())), F.pure) == fa.uncancelable().flatMap(F.pure)
        }
    }

    private static func bracketCaseFailureInAcquisitionRemainsFailure() {
        property("bracketCaseFailureInAcquisitionRemainsFailure") <~ forAll { (e: F.E) in
            let fe = Kind<F, Int>.raiseError(e)
            return fe.bracketCase(constant(F.pure(())), F.pure) == F.raiseError(e)
        }
    }

    private static func bracketIsDerivedFromBracketCase() {
        property("bracketIsDerivedFromBracketCase") <~ forAll { (a: Int) in
            let fa = F.pure(a)
            return fa.bracket(constant(F.pure(())), F.pure) == fa.bracketCase(constant(F.pure(())), F.pure)
        }
    }

    private static func uncancelablePreventsCanceledCase() {
        property("uncancelablePreventsCanceledCase") <~ forAll { (a: Int) in
            let fa = F.pure(a)
            let onCancel = F.pure(())
            let onFinish = F.pure(())
            return F.pure(()).bracketCase({ _, b in (b == ExitCase<F.E>.canceled) ? onCancel : onFinish}, { fa }).uncancelable() ==
                fa.guarantee(onFinish)
        }
    }

    private static func acquireAndReleaseAreUncancelable() {
        property("acquireAndReleaseAreUncancelable") <~ forAll { (a: Int) in
            let fa = F.pure(a)
            let release: (Int) -> Kind<F, ()> = constant(F.pure(()))
            return fa.uncancelable().bracket({ x in release(x).uncancelable() }, F.pure) == fa.bracket(release, F.pure)
        }
    }

    private static func guaranteeIsDerivedFromBracket() {
        property("guaranteeIsDerivedFromBracket") <~ forAll { (a: Int) in
            let fa = F.pure(a)
            let finalizer = F.pure(())
            return fa.guarantee(finalizer) == F.pure(()).bracket({ finalizer }, { fa })
        }
    }

    private static func guaranteeCaseIsDerivedFromBracketCase() {
        property("guaranteeCaseIsDerivedFromBracketCase") <~ forAll { (a: Int) in
            let fa = F.pure(a)
            let finalizer: (ExitCase<F.E>) -> Kind<F, ()> = constant(F.pure(()))
            return fa.guaranteeCase(finalizer) == F.pure(()).bracketCase({ _, e in finalizer(e) }, { fa })
        }
    }

    private static func bracketPropagatesTransformerEffects() {
        property("bracketPropagatesTransformerEffects") <~ forAll { (a: String, f: ArrowOf<String, Int>, g: ArrowOf<String, Int>) in
            let acquire = F.pure(a)
            let use = f.getArrow >>> F.pure
            let release = g.getArrow >>> { _ in F.pure(()) }
            return acquire.bracket(release, use) == acquire.flatMap { x in use(x).flatMap { y in release(x).map { y } } }
        }
    }

    private static func bracketMustRunReleaseTask() {
        property("bracketMustRunReleaseTask") <~ forAll { (a: Int, e: F.E) in
            var msg = 0
            return F.pure(a).bracket({ i in msg = i; return F.pure(()) }, { _ -> Kind<F, Int> in throw e })
                .attempt()
                .map { _ in msg } == F.pure(a)
        }
    }
}
