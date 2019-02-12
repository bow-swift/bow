@testable import Bow

class BimonadLaws<F: Bimonad & EquatableK> {
    
    static func check(generator: @escaping (Int) -> Kind<F, Int>) {
        MonadLaws<F>.check()
        ComonadLaws<F>.check(generator: generator)
    }
}
