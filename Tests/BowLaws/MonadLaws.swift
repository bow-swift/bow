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
        if withStackSafety { 
            stackSafety()
        }
        tailRecMConsistentFlatMap()
        stackSafeFlatMapConsistentWithFlatMap()
        monadComprehensions()
        flatten()
    }
    
    private static func leftIdentity() {
        property("Monad left identity") <~ forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let g = f.getArrow >>> F.pure
            
            return F.pure(a).flatMap(g)
                ==
            g(a)
        }
    }
    
    private static func rightIdentity() {
        property("Monad right identity") <~ forAll { (a: Int) in
            let fa = F.pure(a)
            return fa.flatMap(F.pure)
                ==
            fa
        }
    }
    
    private static func kleisliLeftIdentity() {
        property("Kleisli left identity") <~ forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let g = f.getArrow >>> F.pure
            
            return Kleisli { (n: Int) in F.pure(n) }
                .andThen(Kleisli(g)).run(a)
                ==
            g(a)
        }
    }
    
    private static func kleisliRightIdentity() {
        property("Kleisli right identity") <~ forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let g = f.getArrow >>> F.pure
            
            return Kleisli(g).andThen(F.pure).run(a)
                ==
            g(a)
        }
    }
    
    private static func flatMapCoherence() {
        property("Monad flatMap coherence") <~ forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let g = f.getArrow >>> F.pure
            let fa = F.pure(a)
            
            return fa.flatMap(g)
                ==
            fa.map(f.getArrow)
        }
    }
    
    private static func stackSafety() {
        let iterations = 200000
        let res = Kind<F, Int>.tailRecM(0) { i in
            F.pure( i < iterations ?
                Either.left(i + 1) :
                Either.right(i) )
        }
        
        XCTAssertEqual(res, F.pure(iterations))
    }

    private static func tailRecMConsistentFlatMap() {
        func bounce(n: Int, a: Int, f: @escaping (Int) -> Kind<F, Int>) -> Kind<F, Int> {
            F.tailRecM((a, n)) { arg in
                let (a0, i) = arg
                return (i > 0)
                    ? F.map(f(a0)) { Either.left(($0, i - 1)) }
                    : F.map(f(a0), Either.right)
            }
        }

        /// The `bounce(n, a, f)` function uses `tailRecM` to compute `F.pure(a).flatMap(f).flatMap(f)...` where `.flatMap(f)`
        /// is applied `n+1` times.
        /// We want to assert that this computation gives the same result whether we compute it with `tailRecM`
        /// or we compute it with plain `flatMap`.
        /// We test only for 3 `flatMap` calls, but since `bounce(n) = bounce(n-1).flatMap(f)` we deduce by induction
        /// that the `tailRecM` and the plain `flatMap` computations are equivalent for any `n`.
        property("tailRecM is consistent with flatMap") <~ forAll { (a: Int, f: ArrowOf<Int, KindOf<F, Int>>) in
            let f = { f.getArrow($0).value }
            let bounce1 = bounce(n: 1, a: a, f: f)
            let bounce0 = bounce(n: 0, a: a, f: f).flatMap(f)
            let flat = F.pure(a).flatMap(f).flatMap(f)
            return bounce1 == bounce0 && bounce0 == flat
        }
    }

    private static func stackSafeFlatMapConsistentWithFlatMap() {
        property("stackSafeFlatMap is consistent with flatMap") <~ forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, KindOf<F, String>>) in
            let f = { f.getArrow($0).value }
            return F.flatMap(fa.value, f) == F.stackSafeFlatMap(fa.value, f)
        }
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

        property("Function builder Monad comprehensions") <~ forAll { (a: Int, b: Int, c: Int, d: Int) in
            let fa = F.pure(a)
            let fb = F.pure(b)
            let fc = F.pure(c)
            let fd = F.pure(d)

            let x = Kind<F, Int>.var()
            let y = Kind<F, Int>.var()
            let z = Kind<F, Int>.var()
            let w = Kind<F, Int>.var()

            let result = binding({
                x <-- fa
                y <-- fb
                z <-- fc
                w <-- fd
            }) {
                x.get + y.get + z.get + w.get
            }

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

        property("Function builder Monad comprehensions equivalence to flatMap") <~ forAll { (fa: KindOf<F, Int>, fb: KindOf<F, Double>, fc: KindOf<F, String>) in
            let r1 = fa.value.flatMap { a in
                fb.value.flatMap { b in
                    fc.value.map { c in "\(a), \(b), \(c)" }
                }
            }

            let x = F.var(Int.self)
            let y = F.var(Double.self)
            let z = F.var(String.self)

            let r2 = binding({
                x <-- fa.value
                y <-- fb.value
                z <-- fc.value
            }) {
                "\(x.get), \(y.get), \(z.get)"
            }

            return r1 == r2
        }
    }
    
    private static func flatten() {
        property("Flatten") <~ forAll { (a: Int) in
            F.pure(F.pure(a)).flatten()
                ==
            F.pure(a)
        }
    }
}
