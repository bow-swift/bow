import Foundation
import SwiftCheck
import Nimble
@testable import Bow

class MonadLaws<F> {
    
    static func check<Mon, EqF>(monad : Mon, eq : EqF) where Mon : Monad, Mon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        leftIdentity(monad, eq)
        rightIdentity(monad, eq)
        kleisliLeftIdentity(monad, eq)
        kleisliRightIdentity(monad, eq)
        flatMapCoherence(monad, eq)
        stackSafety(monad, eq)
        monadComprehensions(monad, eq)
    }
    
    private static func leftIdentity<Mon, EqF>(_ monad : Mon, _ eq : EqF) where Mon : Monad, Mon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Monad left identity") <- forAll { (a : Int, b : Int) in
            let f = { (_ : Int) in monad.pure(a) }
            return eq.eqv(monad.flatMap(monad.pure(b), f),
                          f(b))
        }
    }
    
    private static func rightIdentity<Mon, EqF>(_ monad : Mon, _ eq : EqF) where Mon : Monad, Mon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Monad right identity") <- forAll { (a : Int) in
            let fa = monad.pure(a)
            return eq.eqv(monad.flatMap(fa, monad.pure),
                          fa)
        }
    }
    
    private static func kleisliLeftIdentity<Mon, EqF>(_ monad : Mon, _ eq : EqF) where Mon : Monad, Mon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Kleisli left identity") <- forAll { (a : Int, b : Int) in
            let f = { (_ : Int) in monad.pure(a) }
            return eq.eqv(Kleisli({ (n : Int) in monad.pure(n) }).andThen(Kleisli(f), monad).invoke(b),
                          f(b))
        }
    }
    
    private static func kleisliRightIdentity<Mon, EqF>(_ monad : Mon, _ eq : EqF) where Mon : Monad, Mon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Kleisli right identity") <- forAll { (a : Int, b : Int) in
            let f = { (_ : Int) in monad.pure(a) }
            return eq.eqv(Kleisli(f).andThen(monad.pure, monad).invoke(b),
                          f(b))
        }
    }
    
    private static func flatMapCoherence<Mon, EqF>(_ monad : Mon, _ eq : EqF) where Mon : Monad, Mon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Monad flatMap coherence") <- forAll { (a : Int, b : Int) in
            let f = { (_ : Int) in a }
            let fb = monad.pure(b)
            return eq.eqv(monad.flatMap(fb, f >>> monad.pure),
                          monad.map(fb, f))
        }
    }
    
    private static func stackSafety<Mon, EqF>(_ monad : Mon, _ eq : EqF) where Mon : Monad, Mon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        let iterations = 2000
        let res = monad.tailRecM(0, { i in monad.pure( i < iterations ? Either.left(i + 1) : Either.right(i) )})
        expect(eq.eqv(res, monad.pure(iterations))).to(beTrue())
    }
    
    private static func monadComprehensions<Mon, EqF>(_ monad : Mon, _ eq : EqF) where Mon : Monad, Mon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Monad comprehensions") <- forAll { (a : Int) in
            let x = monad.binding({ monad.pure(a) },
                                  { a in monad.pure(a + 1) },
                                  { _, b in monad.pure(b + 1) })
            return eq.eqv(x, monad.pure(a + 2))
        }
    }
}
