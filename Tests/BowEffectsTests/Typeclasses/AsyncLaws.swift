import Foundation
import SwiftCheck
@testable import Bow
@testable import BowEffects

class AsyncLaws<F, E> where E : Error {
    
    static func check<AC, MonErr, EqA>(async : AC, monadError : MonErr, eq : EqA, gen : @escaping () -> E) where AC : Async, AC.F == F, AC.E == E, MonErr : MonadError, MonErr.F == F, MonErr.E == E, EqA : Eq, EqA.A == Kind<F, Int> {
        success(async, monadError, eq)
        error(async, monadError, eq, gen)
    }
    
    private static func success<AC, MonErr, EqA>(_ async : AC, _ monadError : MonErr, _ eq : EqA) where AC : Async, AC.F == F, MonErr : MonadError, MonErr.F == F, MonErr.E == E, EqA : Eq, EqA.A == Kind<F, Int> {
        
        property("Success equivalence") <- forAll { (a : Int) in
            return eq.eqv(async.runAsync({ ff in ff(Either<Error, Int>.right(a)) }),
                          monadError.pure(a))
        }
    }
    
    private static func error<AC, MonErr, EqA>(_ asyncContext : AC, _ monadError : MonErr, _ eq : EqA, _ gen : @escaping () -> E) where AC : Async, AC.F == F, MonErr : MonadError, MonErr.F == F, MonErr.E == E, EqA : Eq, EqA.A == Kind<F, Int> {
        
        property("Error equivalence") <- forAll { (_ : Int) in
            let error = gen()
            return eq.eqv(asyncContext.runAsync({ ff in ff(Either<Error, Int>.left(error)) }),
                          monadError.raiseError(error))
        }
    }
}
