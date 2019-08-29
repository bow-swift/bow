import Bow
import BowGenerators

public class BimonadLaws<F: Bimonad & EquatableK & ArbitraryK> {
    public static func check() {
        MonadLaws<F>.check()
        ComonadLaws<F>.check()
    }
}
