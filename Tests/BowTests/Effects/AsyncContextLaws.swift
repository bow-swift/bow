import Foundation
import SwiftCheck
@testable import Bow

class AsyncContextLaws<F> {
    
    static func check<AC, MonErr, EqA>(asyncContext : AC, monadError : MonErr, eq : EqA, gen : @escaping () -> Error) where AC : AsyncContext, AC.F == F, MonErr : MonadError, MonErr.F == F, MonErr.E == Error, EqA : Eq, EqA.A == Kind<F, Int> {
        success(asyncContext, monadError, eq)
        error(asyncContext, monadError, eq, gen)
    }
    
    private static func success<AC, MonErr, EqA>(_ asyncContext : AC, _ monadError : MonErr, _ eq : EqA) where AC : AsyncContext, AC.F == F, MonErr : MonadError, MonErr.F == F, MonErr.E == Error, EqA : Eq, EqA.A == Kind<F, Int> {
        
        property("Success equivalence") <- forAll { (a : Int) in
            return eq.eqv(asyncContext.runAsync({ ff in ff(Either<Error, Int>.right(a)) }),
                          monadError.pure(a))
        }
    }
    
    private static func error<AC, MonErr, EqA>(_ asyncContext : AC, _ monadError : MonErr, _ eq : EqA, _ gen : @escaping () -> Error) where AC : AsyncContext, AC.F == F, MonErr : MonadError, MonErr.F == F, MonErr.E == Error, EqA : Eq, EqA.A == Kind<F, Int> {
        
        property("Error equivalence") <- forAll { (_ : Int) in
            let error = gen()
            return eq.eqv(asyncContext.runAsync({ ff in ff(Either<Error, Int>.left(error)) }),
                          monadError.raiseError(error))
        }
    }
}
