import Bow
import BowGenerators

class BimonadLaws<F: Bimonad & EquatableK & ArbitraryK> {
    
    static func check() {
        MonadLaws<F>.check()
        ComonadLaws<F>.check()
    }
}
