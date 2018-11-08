import Foundation
import SwiftCheck
@testable import Bow

class MonadErrorLaws<F, E> {
    
    static func check<MonErr, EqF>(monadError : MonErr, eq : EqF, gen : @escaping () -> E) where MonErr : MonadError, MonErr.F == F, MonErr.E == E, EqF : Eq, EqF.A == Kind<F, Int> {
        leftZero(monadError, eq, gen)
        ensureConsistency(monadError, eq, gen)
    }
    
    private static func leftZero<MonErr, EqF>(_ monadError : MonErr, _ eq : EqF, _ gen : @escaping () -> E) where MonErr : MonadError, MonErr.F == F, MonErr.E == E, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Left zero") <- forAll { (a : Int) in
            let error = gen()
            let f = { (_ : Int) in monadError.pure(a) }
            return eq.eqv(monadError.flatMap(monadError.raiseError(error), f),
                          monadError.raiseError(error))
        }
    }
    
    private static func ensureConsistency<MonErr, EqF>(_ monadError : MonErr, _ eq : EqF, _ gen : @escaping () -> E) where MonErr : MonadError, MonErr.F == F, MonErr.E == E, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Ensure consistency") <- forAll { (a : Int, p : ArrowOf<Int, Bool>) in
            let error = gen()
            let fa = monadError.pure(a)
            return eq.eqv(monadError.ensure(fa, error: { error }, predicate: p.getArrow),
                          monadError.flatMap(fa, { a in p.getArrow(a) ? monadError.pure(a) : monadError.raiseError(error) }))
        }
    }
    
}
