@testable import Bow

class BimonadLaws<F> {
    
    static func check<Bimon, EqF>(bimonad : Bimon, generator : @escaping (Int) -> Kind<F, Int>, eq : EqF) where Bimon : Bimonad, Bimon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        MonadLaws<F>.check(monad: bimonad, eq: eq)
        ComonadLaws<F>.check(comonad: bimonad, generator: generator, eq: eq)
    }
}
