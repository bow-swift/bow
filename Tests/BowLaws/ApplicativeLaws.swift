import Foundation
import SwiftCheck
import Bow
import BowGenerators

public class ApplicativeLaws<F: Applicative & EquatableK & ArbitraryK> {
    public static func check() {
        apIdentity()
        homomorphism()
        interchange()
        mapDerived()
        cartesianBuilderMap()
    }
    
    private static func apIdentity() {
        property("ap identity") <~ forAll() { (fa: KindOf<F, Int>) in
            
            F.pure(id).ap(fa.value)
                ==
            fa.value
        }
    }
    
    private static func homomorphism() {
        property("homomorphism") <~ forAll() { (a: Int, f: ArrowOf<Int, Int>) in
            
            F.pure(f.getArrow).ap(F.pure(a))
                ==
            F.pure(f.getArrow(a))
        }
    }
    
    private static func interchange() {
        property("interchange") <~ forAll() { (a: Int, b: Int) in
            let fa = F.pure(constant(a) as (Int) -> Int)
            
            return fa.ap(F.pure(b))
                ==
            F.pure({ (x: (Int) -> Int) in x(a) } ).ap(fa)
        }
    }
    
    private static func mapDerived() {
        property("map derived") <~ forAll() { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            
            fa.value.map(f.getArrow)
                ==
            F.pure(f.getArrow).ap(fa.value)
        }
    }
    
    private static func cartesianBuilderMap() {
        property("Map with 2 inputs") <~ forAll { (a: Int, b: Int) in
            
            Kind<F, Int>.map(
                .pure(a),
                .pure(b)) { a1, b1 in
                    a1 + b1
            }
                ==
            Kind<F, Int>.pure(a + b)
        }
        
        property("Map with 3 inputs") <~ forAll { (a: Int, b: Int, c: Int) in
            
            Kind<F, Int>.map(
                .pure(a),
                .pure(b),
                .pure(c)) { a1, b1, c1 in
                    a1 + b1 + c1
            }
                ==
            Kind<F, Int>.pure(a + b + c)
        }
        
        property("Map with 4 inputs") <~ forAll { (a: Int, b: Int, c: Int, d: Int) in
            
            Kind<F, Int>.map(
                .pure(a),
                .pure(b),
                .pure(c),
                .pure(d)) { a1, b1, c1, d1 in
                    a1 + b1 + c1 + d1
            }
                ==
            Kind<F, Int>.pure(a + b + c + d)
        }
        
        property("Map with 5 inputs") <~ forAll { (a: Int, b: Int, c: Int, d: Int, e: Int) in
            
            Kind<F, Int>.map(
                Kind<F, Int>.pure(a),
                Kind<F, Int>.pure(b),
                Kind<F, Int>.pure(c),
                Kind<F, Int>.pure(d),
                Kind<F, Int>.pure(e)) { a1, b1, c1, d1, e1 in
                    a1 + b1 + c1 + d1 + e1
            }
                ==
            Kind<F, Int>.pure(a + b + c + d + e)
        }

        property("Map with 6 inputs") <~ forAll { (a: Int, b: Int, c: Int, d: Int, e: Int, f: Int) -> Bool in
            
            Kind<F, Int>.map(
                Kind<F, Int>.pure(a),
                Kind<F, Int>.pure(b),
                Kind<F, Int>.pure(c),
                Kind<F, Int>.pure(d),
                Kind<F, Int>.pure(e),
                Kind<F, Int>.pure(f)) { (a1: Int, b1: Int, c1: Int, d1: Int, e1: Int, f1: Int) -> Int in
                    a1 + b1 + c1 + d1 + e1 + f1
            }
                ==
            Kind<F, Int>.pure(a + b + c + d + e + f)
        }
        
        property("Map with 7 inputs") <~ forAll { (a: Int, b: Int, c: Int, d: Int, e: Int, f: Int, g: Int) -> Bool in
            
            Kind<F, Int>.map(
                Kind<F, Int>.pure(a),
                Kind<F, Int>.pure(b),
                Kind<F, Int>.pure(c),
                Kind<F, Int>.pure(d),
                Kind<F, Int>.pure(e),
                Kind<F, Int>.pure(f),
                Kind<F, Int>.pure(g)) { (a1: Int, b1: Int, c1: Int, d1: Int, e1: Int, f1: Int, g1: Int) -> Int in
                    a1 + b1 + c1 + d1 + e1 + f1 + g1
            }
                ==
            Kind<F, Int>.pure(a + b + c + d + e + f + g)
        }
        
        property("Map with 8 inputs") <~ forAll { (a: Int, b: Int, c: Int, d: Int, e: Int, f: Int, g: Int, h: Int) -> Bool in
            
            Kind<F, Int>.map(
                Kind<F, Int>.pure(a),
                Kind<F, Int>.pure(b),
                Kind<F, Int>.pure(c),
                Kind<F, Int>.pure(d),
                Kind<F, Int>.pure(e),
                Kind<F, Int>.pure(f),
                Kind<F, Int>.pure(g),
                Kind<F, Int>.pure(h)) { (a1: Int, b1: Int, c1: Int, d1: Int, e1: Int, f1: Int, g1: Int, h1: Int) -> Int in
                    a1 + b1 + c1 + d1 + e1 + f1 + g1 + h1
            }
                ==
            Kind<F, Int>.pure(a + b + c + d + e + f + g + h)
        }
        
        property("Map with 9 inputs") <~ forAll { (a: Int, b: Int, c: Int, d: Int, e: Int, f: Int, g: Int, h: Int) -> Bool in
            
            Kind<F, Int>.map(
                Kind<F, Int>.pure(a),
                Kind<F, Int>.pure(b),
                Kind<F, Int>.pure(c),
                Kind<F, Int>.pure(d),
                Kind<F, Int>.pure(e),
                Kind<F, Int>.pure(f),
                Kind<F, Int>.pure(g),
                Kind<F, Int>.pure(h),
                Kind<F, Int>.pure(a)) { (a1: Int, b1: Int, c1: Int, d1: Int, e1: Int, f1: Int, g1: Int, h1: Int, i1: Int) -> Int in
                    a1 + b1 + c1 + d1 + e1 + f1 + g1 + h1 + i1
            }
                ==
            Kind<F, Int>.pure(a + b + c + d + e + f + g + h + a)
        }
    }
}
