import Bow
import BowGenerators

class MonadCombineLaws<F: MonadCombine & EquatableK & ArbitraryK> {
    static func check() {
        AlternativeLaws<F>.check()
        MonadFilterLaws<F>.check(generator: F.pure)
    }
}
