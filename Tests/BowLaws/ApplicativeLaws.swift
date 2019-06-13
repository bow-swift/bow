import Foundation
import SwiftCheck
import Bow
import BowGenerators

class ApplicativeLaws<F: Applicative & EquatableK & ArbitraryK> {
    static func check() {
        apIdentity()
        homomorphism()
        interchange()
        mapDerived()
        cartesianBuilderMap()
        cartesianBuilderTupled()
        mapWithMultipleInputs()
    }
    
    private static func apIdentity() {
        property("ap identity") <- forAll() { (fa: KindOf<F, Int>) in
            return F.ap(F.pure(id), fa.value) == fa.value
        }
    }
    
    private static func homomorphism() {
        property("homomorphism") <- forAll() { (a: Int, f: ArrowOf<Int, Int>) in
            return F.ap(F.pure(f.getArrow), F.pure(a)) == F.pure(f.getArrow(a))
        }
    }
    
    private static func interchange() {
        property("interchange") <- forAll() { (a: Int, b: Int) in
            let fa = F.pure(constant(a) as (Int) -> Int)
            return F.ap(fa, F.pure(b)) == F.ap(F.pure({ (x: (Int) -> Int) in x(a) } ), fa)
        }
    }
    
    private static func mapDerived() {
        property("mad derived") <- forAll() { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            return F.map(fa.value, f.getArrow) == F.ap(F.pure(f.getArrow), fa.value)
        }
    }
    
    private static func cartesianBuilderMap() {
        property("cartesian builder map") <- forAll() { (a: Int, b: Int, c: Int, d: Int, e: Int, f: Int, g: Int) in
            let left: Kind<F, Int> = F.map(F.pure(a), F.pure(b), F.pure(c), F.pure(d), F.pure(e), F.pure(f), { x, y, z, u, v, w in x + y + z - u - v - w })
            let right: Kind<F, Int> = F.pure(a + b + c - d - e - f)
            return left == right
        }
    }
    
    private static func cartesianBuilderTupled() {
        property("cartesian builder map") <- forAll() { (a: Int, b: Int, c: Int, d: Int, e: Int, f: Int, g: Int) in
            let left: Kind<F, Int> = F.map(F.tupled(F.pure(a), F.pure(b), F.pure(c), F.pure(d), F.pure(e), F.pure(f)), { x, y, z, u, v, w in x + y + z - u - v - w })
            let right: Kind<F, Int> = F.pure(a + b + c - d - e - f)
            return left == right
        }
    }
    
    private static func mapWithMultipleInputs() {
        property("Map with 2 inputs") <- forAll { (a: Int, b: Int) in
            return F.map(F.pure(a), F.pure(b), { a1, b1 in a1 + b1 }) == F.pure(a + b)
        }
        
        property("Map with 3 inputs") <- forAll { (a: Int, b: Int, c: Int) in
            let left: Kind<F, Int> = F.map(F.pure(a), F.pure(b), F.pure(c), { a1, b1, c1 in a1 + b1 + c1 })
            let right: Kind<F, Int> = F.pure(a + b + c)
            return left == right
        }
        
        property("Map with 4 inputs") <- forAll { (a: Int, b: Int, c: Int, d: Int) in
            let left: Kind<F, Int> = F.map(F.pure(a), F.pure(b), F.pure(c), F.pure(d), { a1, b1, c1, d1 in a1 + b1 + c1 + d1 })
            let right: Kind<F, Int> = F.pure(a + b + c + d)
            return left == right
        }
        
        property("Map with 5 inputs") <- forAll { (a: Int, b: Int, c: Int, d: Int, e: Int) in
            let left: Kind<F, Int> = F.map(F.pure(a), F.pure(b), F.pure(c), F.pure(d), F.pure(e), { a1, b1, c1, d1, e1 in a1 + b1 + c1 + d1 + e1 })
            let right: Kind<F, Int> = F.pure(a + b + c + d + e)
            return left == right
        }

        property("Map with 6 inputs") <- forAll { (a: Int, b: Int, c: Int, d: Int, e: Int, f: Int) in
            let left: Kind<F, Int> = F.map(F.pure(a), F.pure(b), F.pure(c), F.pure(d), F.pure(e), F.pure(f), { a1, b1, c1, d1, e1, f1 in a1 + b1 + c1 + d1 + e1 + f1 })
            let right: Kind<F, Int> = F.pure(a + b + c + d + e + f)
            return left == right
        }
        
        property("Map with 7 inputs") <- forAll { (a: Int, b: Int, c: Int, d: Int, e: Int, f: Int, g: Int) in
            let left: Kind<F, Int> = F.map(F.pure(a), F.pure(b), F.pure(c), F.pure(d), F.pure(e), F.pure(f), F.pure(g), { a1, b1, c1, d1, e1, f1, g1 in a1 + b1 + c1 + d1 + e1 + f1 + g1 })
            let right: Kind<F, Int> = F.pure(a + b + c + d + e + f + g)
            return left == right
        }
        
        property("Map with 8 inputs") <- forAll { (a: Int, b: Int, c: Int, d: Int, e: Int, f: Int, g: Int, h: Int) in
            let left: Kind<F, Int> = F.map(F.pure(a), F.pure(b), F.pure(c), F.pure(d), F.pure(e), F.pure(f), F.pure(g), F.pure(h), { a1, b1, c1, d1, e1, f1, g1, h1 in a1 + b1 + c1 + d1 + e1 + f1 + g1 + h1 })
            let right: Kind<F, Int> = F.pure(a + b + c + d + e + f + g + h)
            return left == right
        }
        
        property("Map with 9 inputs") <- forAll { (a: Int, b: Int, c: Int, d: Int, e: Int, f: Int, g: Int, h: Int) in
            let left: Kind<F, Int> = F.map(F.pure(a), F.pure(b), F.pure(c), F.pure(d), F.pure(e), F.pure(f), F.pure(g), F.pure(h), F.pure(a), { a1, b1, c1, d1, e1, f1, g1, h1, i1 in a1 + b1 + c1 + d1 + e1 + f1 + g1 + h1 + i1 })
            let right: Kind<F, Int> = F.pure(a + b + c + d + e + f + g + h + a)
            return left == right
        }
    }
}
