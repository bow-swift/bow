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
        //stackSafety(monad, eq) FIXME truizlop: some implementations are not 100% stack safe
        monadComprehensions(monad, eq)
        flatten(monad, eq)
    }
    
    private static func leftIdentity<Mon, EqF>(_ monad : Mon, _ eq : EqF) where Mon : Monad, Mon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Monad left identity") <- forAll { (a : Int, f : ArrowOf<Int, Int>) in
            let g = f.getArrow >>> monad.pure
            return eq.eqv(monad.flatMap(monad.pure(a), g),
                          g(a))
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
        property("Kleisli left identity") <- forAll { (a : Int, f : ArrowOf<Int, Int>) in
            let g = f.getArrow >>> monad.pure
            return eq.eqv(Kleisli({ (n : Int) in monad.pure(n) }).andThen(Kleisli(g), monad).invoke(a),
                          g(a))
        }
    }
    
    private static func kleisliRightIdentity<Mon, EqF>(_ monad : Mon, _ eq : EqF) where Mon : Monad, Mon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Kleisli right identity") <- forAll { (a : Int, f : ArrowOf<Int, Int>) in
            let g = f.getArrow >>> monad.pure
            return eq.eqv(Kleisli(g).andThen(monad.pure, monad).invoke(a),
                          g(a))
        }
    }
    
    private static func flatMapCoherence<Mon, EqF>(_ monad : Mon, _ eq : EqF) where Mon : Monad, Mon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Monad flatMap coherence") <- forAll { (a : Int, f : ArrowOf<Int, Int>) in
            let g = f.getArrow >>> monad.pure
            let fa = monad.pure(a)
            return eq.eqv(monad.flatMap(fa, g),
                          monad.map(fa, f.getArrow))
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
                                  { a in monad.pure(a + 1) })
            return eq.eqv(x, monad.pure(a + 1))
        }
        
        property("Monad comprehensions") <- forAll { (a : Int) in
            let x = monad.binding({ monad.pure(a) },
                                  { a in monad.pure(a + 1) },
                                  { _, b in monad.pure(b + 1) })
            return eq.eqv(x, monad.pure(a + 2))
        }
        
        property("Monad comprehensions") <- forAll { (a : Int) in
            let x = monad.binding({ monad.pure(a) },
                                  { a in monad.pure(a + 1) },
                                  { _, b in monad.pure(b + 1) },
                                  { _, _, c in monad.pure(c + 1) })
            return eq.eqv(x, monad.pure(a + 3))
        }
        
        property("Monad comprehensions") <- forAll { (a : Int) in
            let x = monad.binding({ monad.pure(a) },
                                  { a in monad.pure(a + 1) },
                                  { _, b in monad.pure(b + 1) },
                                  { _, _, c in monad.pure(c + 1) },
                                  { _, _, _, d in monad.pure(d + 1) })
            return eq.eqv(x, monad.pure(a + 4))
        }
        
        property("Monad comprehensions") <- forAll { (a : Int) in
            let x = monad.binding({ monad.pure(a) },
                                  { a in monad.pure(a + 1) },
                                  { _, b in monad.pure(b + 1) },
                                  { _, _, c in monad.pure(c + 1) },
                                  { _, _, _, d in monad.pure(d + 1) },
                                  { _, _, _, _, e in monad.pure(e + 1) })
            return eq.eqv(x, monad.pure(a + 5))
        }
        
        property("Monad comprehensions") <- forAll { (a : Int) in
            let x = monad.binding({ monad.pure(a) },
                                  { a in monad.pure(a + 1) },
                                  { _, b in monad.pure(b + 1) },
                                  { _, _, c in monad.pure(c + 1) },
                                  { _, _, _, d in monad.pure(d + 1) },
                                  { _, _, _, _, e in monad.pure(e + 1) },
                                  { _, _, _, _, _, f in monad.pure(f + 1) })
            return eq.eqv(x, monad.pure(a + 6))
        }
        
        property("Monad comprehensions") <- forAll { (a : Int) in
            let x = monad.binding({ monad.pure(a) },
                                  { a in monad.pure(a + 1) },
                                  { _, b in monad.pure(b + 1) },
                                  { _, _, c in monad.pure(c + 1) },
                                  { _, _, _, d in monad.pure(d + 1) },
                                  { _, _, _, _, e in monad.pure(e + 1) },
                                  { _, _, _, _, _, f in monad.pure(f + 1) },
                                  { _, _, _, _, _, _, g in monad.pure(g + 1) })
            return eq.eqv(x, monad.pure(a + 7))
        }
        
        property("Monad comprehensions") <- forAll { (a : Int) in
            let x = monad.binding({ monad.pure(a) },
                                  { a in monad.pure(a + 1) },
                                  { _, b in monad.pure(b + 1) },
                                  { _, _, c in monad.pure(c + 1) },
                                  { _, _, _, d in monad.pure(d + 1) },
                                  { _, _, _, _, e in monad.pure(e + 1) },
                                  { _, _, _, _, _, f in monad.pure(f + 1) },
                                  { _, _, _, _, _, _, g in monad.pure(g + 1) },
                                  { _, _, _, _, _, _, _, h in monad.pure(h + 1) })
            return eq.eqv(x, monad.pure(a + 8))
        }
    }
    
    private static func flatten<Mon, EqF>(_ monad : Mon, _ eq : EqF) where Mon : Monad, Mon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Flatten") <- forAll { (a : Int) in
            return eq.eqv(monad.flatten(monad.pure(monad.pure(a))),
                          monad.pure(a))
        }
    }
}
