import Foundation
import SwiftCheck
import Nimble
import Bow
import BowGenerators

class MonadLaws<F: Monad & EquatableK & ArbitraryK> {
    static func check() {
        leftIdentity()
        rightIdentity()
        kleisliLeftIdentity()
        kleisliRightIdentity()
        flatMapCoherence()
        //stackSafety() FIXME truizlop: some implementations are not 100% stack safe
        monadComprehensions()
        flatten()
    }
    
    private static func leftIdentity() {
        property("Monad left identity") <- forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let g = f.getArrow >>> F.pure
            return F.flatMap(F.pure(a), g) == g(a)
        }
    }
    
    private static func rightIdentity() {
        property("Monad right identity") <- forAll { (a: Int) in
            let fa = F.pure(a)
            return F.flatMap(fa, F.pure) == fa
        }
    }
    
    private static func kleisliLeftIdentity() {
        property("Kleisli left identity") <- forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let g = f.getArrow >>> F.pure
            return Kleisli({ (n : Int) in F.pure(n) }).andThen(Kleisli(g)).invoke(a) == g(a)
        }
    }
    
    private static func kleisliRightIdentity() {
        property("Kleisli right identity") <- forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let g = f.getArrow >>> F.pure
            return Kleisli(g).andThen(F.pure).invoke(a) == g(a)
        }
    }
    
    private static func flatMapCoherence() {
        property("Monad flatMap coherence") <- forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let g = f.getArrow >>> F.pure
            let fa = F.pure(a)
            return F.flatMap(fa, g) == F.map(fa, f.getArrow)
        }
    }
    
    private static func stackSafety() {
        let iterations = 2000
        let res = F.tailRecM(0, { i in F.pure( i < iterations ? Either.left(i + 1) : Either.right(i) )})
        expect(res == F.pure(iterations)).to(beTrue())
    }
    
    private static func monadComprehensions() {
        property("Monad comprehensions") <- forAll { (a: Int) in
            let x = F.binding({ F.pure(a) },
                                  { a in F.pure(a + 1) })
            return x == F.pure(a + 1)
        }
        
        property("Monad comprehensions") <- forAll { (a: Int) in
            let x = F.binding({ F.pure(a) },
                                  { a in F.pure(a + 1) },
                                  { _, b in F.pure(b + 1) })
            return x == F.pure(a + 2)
        }
        
        property("Monad comprehensions") <- forAll { (a: Int) in
            let x = F.binding({ F.pure(a) },
                                  { a in F.pure(a + 1) },
                                  { _, b in F.pure(b + 1) },
                                  { _, _, c in F.pure(c + 1) })
            return x == F.pure(a + 3)
        }
        
        property("Monad comprehensions") <- forAll { (a: Int) in
            let x = F.binding({ F.pure(a) },
                                  { a in F.pure(a + 1) },
                                  { _, b in F.pure(b + 1) },
                                  { _, _, c in F.pure(c + 1) },
                                  { _, _, _, d in F.pure(d + 1) })
            return x == F.pure(a + 4)
        }
        
        property("Monad comprehensions") <- forAll { (a: Int) in
            let x = F.binding({ F.pure(a) },
                                  { a in F.pure(a + 1) },
                                  { _, b in F.pure(b + 1) },
                                  { _, _, c in F.pure(c + 1) },
                                  { _, _, _, d in F.pure(d + 1) },
                                  { _, _, _, _, e in F.pure(e + 1) })
            return x == F.pure(a + 5)
        }
        
        property("Monad comprehensions") <- forAll { (a: Int) in
            let x = F.binding({ F.pure(a) },
                                  { a in F.pure(a + 1) },
                                  { _, b in F.pure(b + 1) },
                                  { _, _, c in F.pure(c + 1) },
                                  { _, _, _, d in F.pure(d + 1) },
                                  { _, _, _, _, e in F.pure(e + 1) },
                                  { _, _, _, _, _, f in F.pure(f + 1) })
            return x == F.pure(a + 6)
        }
        
        property("Monad comprehensions") <- forAll { (a: Int) in
            let x = F.binding({ F.pure(a) },
                                  { a in F.pure(a + 1) },
                                  { _, b in F.pure(b + 1) },
                                  { _, _, c in F.pure(c + 1) },
                                  { _, _, _, d in F.pure(d + 1) },
                                  { _, _, _, _, e in F.pure(e + 1) },
                                  { _, _, _, _, _, f in F.pure(f + 1) },
                                  { _, _, _, _, _, _, g in F.pure(g + 1) })
            return x == F.pure(a + 7)
        }
        
        property("Monad comprehensions") <- forAll { (a: Int) in
            let x = F.binding({ F.pure(a) },
                                  { a in F.pure(a + 1) },
                                  { _, b in F.pure(b + 1) },
                                  { _, _, c in F.pure(c + 1) },
                                  { _, _, _, d in F.pure(d + 1) },
                                  { _, _, _, _, e in F.pure(e + 1) },
                                  { _, _, _, _, _, f in F.pure(f + 1) },
                                  { _, _, _, _, _, _, g in F.pure(g + 1) },
                                  { _, _, _, _, _, _, _, h in F.pure(h + 1) })
            return x == F.pure(a + 8)
        }
    }
    
    private static func flatten() {
        property("Flatten") <- forAll { (a: Int) in
            return F.flatten(F.pure(F.pure(a))) == F.pure(a)
        }
    }
}
