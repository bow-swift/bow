@testable import Bow

class MonadCombineLaws<F> {
    static func check<MonComb, EqA>(monadCombine : MonComb, eq : EqA) where MonComb : MonadCombine, MonComb.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        AlternativeLaws.check(alternative: monadCombine, eq: eq)
        MonadFilterLaws.check(monadFilter: monadCombine, generator: monadCombine.pure, eq: eq)
    }
}
