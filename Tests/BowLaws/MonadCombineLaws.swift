import Bow
import BowGenerators

public class MonadCombineLaws<F: MonadCombine & EquatableK & ArbitraryK> {
    public static func check() {
        AlternativeLaws<F>.check()
        MonadFilterLaws<F>.check()
    }
}
