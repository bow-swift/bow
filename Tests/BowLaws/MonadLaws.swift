import SwiftCheck
import Nimble
import Bow
import BowGenerators

public class MonadLaws<F: Monad & EquatableK & ArbitraryK> {
    public static func check() {
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
        property("Monad left identity") <~ forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let g = f.getArrow >>> F.pure
            return F.flatMap(F.pure(a), g) == g(a)
        }
    }
    
    private static func rightIdentity() {
        property("Monad right identity") <~ forAll { (a: Int) in
            let fa = F.pure(a)
            return F.flatMap(fa, F.pure) == fa
        }
    }
    
    private static func kleisliLeftIdentity() {
        property("Kleisli left identity") <~ forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let g = f.getArrow >>> F.pure
            return Kleisli({ (n : Int) in F.pure(n) }).andThen(Kleisli(g)).invoke(a) == g(a)
        }
    }
    
    private static func kleisliRightIdentity() {
        property("Kleisli right identity") <~ forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let g = f.getArrow >>> F.pure
            return Kleisli(g).andThen(F.pure).invoke(a) == g(a)
        }
    }
    
    private static func flatMapCoherence() {
        property("Monad flatMap coherence") <~ forAll { (a: Int, f: ArrowOf<Int, Int>) in
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
        property("Monad comprehensions") <~ forAll { (a: Int, b: Int, c: Int, d: Int) in
            let fa = F.pure(a)
            let fb = F.pure(b)
            let fc = F.pure(c)
            let fd = F.pure(d)
            
            let x = Kind<F, Int>.var()
            let y = Kind<F, Int>.var()
            let z = Kind<F, Int>.var()
            let w = Kind<F, Int>.var()
            
            let result = binding(
                x <-- fa,
                y <-- fb,
                z <-- fc,
                w <-- fd,
                yield: x.get + y.get + z.get + w.get)
            return result == F.pure(a + b + c + d)
        }
    }
    
    private static func flatten() {
        property("Flatten") <~ forAll { (a: Int) in
            return F.flatten(F.pure(F.pure(a))) == F.pure(a)
        }
    }
}
