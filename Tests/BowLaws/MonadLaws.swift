import SwiftCheck
import Bow
import BowGenerators
import XCTest

public class MonadLaws<F: Monad & EquatableK & ArbitraryK> {
    public static func check(withStackSafety: Bool = true) {
        leftIdentity()
        rightIdentity()
        kleisliLeftIdentity()
        kleisliRightIdentity()
        flatMapCoherence()
        if withStackSafety { #warning("All implementations should be stack safe, this is temporary")
            stackSafety()
        }
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
            return Kleisli({ (n : Int) in F.pure(n) }).andThen(Kleisli(g)).run(a) == g(a)
        }
    }
    
    private static func kleisliRightIdentity() {
        property("Kleisli right identity") <~ forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let g = f.getArrow >>> F.pure
            return Kleisli(g).andThen(F.pure).run(a) == g(a)
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
        let iterations = 200000
        let res = F.tailRecM(0, { i in F.pure( i < iterations ? Either.left(i + 1) : Either.right(i) )})
        
        XCTAssertEqual(res, F.pure(iterations))
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
        
        property("Monad comprehensions equivalence to flatMap") <~ forAll { (fa: KindOf<F, Int>, fb: KindOf<F, Double>, fc: KindOf<F, String>) in
            let r1 = fa.value.flatMap { a in
                fb.value.flatMap { b in
                    fc.value.map { c in "\(a), \(b), \(c)" }
                }
            }
            
            let x = F.var(Int.self)
            let y = F.var(Double.self)
            let z = F.var(String.self)
            
            let r2 = binding(
                x <-- fa.value,
                y <-- fb.value,
                z <-- fc.value,
                yield: "\(x.get), \(y.get), \(z.get)"
            )
            
            return r1 == r2
        }
    }
    
    private static func flatten() {
        property("Flatten") <~ forAll { (a: Int) in
            return F.flatten(F.pure(F.pure(a))) == F.pure(a)
        }
    }
}
