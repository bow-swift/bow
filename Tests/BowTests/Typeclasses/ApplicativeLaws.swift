import Foundation
import SwiftCheck
@testable import Bow

class ApplicativeLaws<F> {
    
    static func check<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        apIdentity(applicative: applicative, eq: eq)
        homomorphism(applicative: applicative, eq: eq)
        interchange(applicative: applicative, eq: eq)
        mapDerived(applicative: applicative, eq: eq)
        cartesianBuilderMap(applicative: applicative, eq: eq)
        cartesianBuilderTupled(applicative: applicative, eq: eq)
        mapWithMultipleInputs(applicative: applicative, eq: eq)
    }
    
    private static func apIdentity<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("ap identity") <- forAll() { (a : Int) in
            return eq.eqv(applicative.ap(applicative.pure(a), applicative.pure(id)),
                          applicative.pure(a))
        }
    }
    
    private static func homomorphism<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("homomorphism") <- forAll() { (a : Int, f : ArrowOf<Int, Int>) in
            return eq.eqv(applicative.ap(applicative.pure(a), applicative.pure(f.getArrow)),
                          applicative.pure(f.getArrow(a)))
        }
    }
    
    private static func interchange<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("interchange") <- forAll() { (a : Int, b : Int) in
            let fa = applicative.pure(constant(a) as (Int) -> Int)
            return eq.eqv(applicative.ap(applicative.pure(b), fa),
                          applicative.ap(fa, applicative.pure({ (x : (Int) -> Int) in x(a) } )))
        }
    }
    
    private static func mapDerived<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("mad derived") <- forAll() { (a : Int, f : ArrowOf<Int, Int>) in
            let fa = applicative.pure(a)
            return eq.eqv(applicative.map(fa, f.getArrow),
                          applicative.ap(fa, applicative.pure(f.getArrow)))
            
        }
    }
    
    private static func cartesianBuilderMap<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("cartesian builder map") <- forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int, f : Int, g : Int) in
            return eq.eqv(applicative.map(applicative.pure(a), applicative.pure(b), applicative.pure(c), applicative.pure(d), applicative.pure(e), applicative.pure(f), { x, y, z, u, v, w in x + y + z - u - v - w }),
                          applicative.pure(a + b + c - d - e - f))
        }
    }
    
    private static func cartesianBuilderTupled<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("cartesian builder map") <- forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int, f : Int, g : Int) in
            return eq.eqv(applicative.map(applicative.tupled(applicative.pure(a), applicative.pure(b), applicative.pure(c), applicative.pure(d), applicative.pure(e), applicative.pure(f)), { x, y, z, u, v, w in x + y + z - u - v - w }),
                          applicative.pure(a + b + c - d - e - f))
        }
    }
    
    private static func mapWithMultipleInputs<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("Map with 2 inputs") <- forAll { (a : Int, b : Int) in
            return eq.eqv(applicative.map(applicative.pure(a), applicative.pure(b), { a1, b1 in a1 + b1 }),
                          applicative.pure(a + b))
        }
        
        property("Map with 3 inputs") <- forAll { (a : Int, b : Int, c : Int) in
            return eq.eqv(applicative.map(applicative.pure(a), applicative.pure(b), applicative.pure(c), { a1, b1, c1 in a1 + b1 + c1 }),
                          applicative.pure(a + b + c))
        }
        
        property("Map with 4 inputs") <- forAll { (a : Int, b : Int, c : Int, d : Int) in
            return eq.eqv(applicative.map(applicative.pure(a), applicative.pure(b), applicative.pure(c), applicative.pure(d), { a1, b1, c1, d1 in a1 + b1 + c1 + d1 }),
                          applicative.pure(a + b + c + d))
        }
        
        property("Map with 5 inputs") <- forAll { (a : Int, b : Int, c : Int, d : Int, e : Int) in
            return eq.eqv(applicative.map(applicative.pure(a), applicative.pure(b), applicative.pure(c), applicative.pure(d), applicative.pure(e), { a1, b1, c1, d1, e1 in a1 + b1 + c1 + d1 + e1 }),
                          applicative.pure(a + b + c + d + e))
        }

        property("Map with 6 inputs") <- forAll { (a : Int, b : Int, c : Int, d : Int, e : Int, f : Int) in
            return eq.eqv(applicative.map(applicative.pure(a), applicative.pure(b), applicative.pure(c), applicative.pure(d), applicative.pure(e), applicative.pure(f), { a1, b1, c1, d1, e1, f1 in a1 + b1 + c1 + d1 + e1 + f1 }),
                          applicative.pure(a + b + c + d + e + f))
        }
        
        property("Map with 7 inputs") <- forAll { (a : Int, b : Int, c : Int, d : Int, e : Int, f : Int, g : Int) in
            return eq.eqv(applicative.map(applicative.pure(a), applicative.pure(b), applicative.pure(c), applicative.pure(d), applicative.pure(e), applicative.pure(f), applicative.pure(g), { a1, b1, c1, d1, e1, f1, g1 in a1 + b1 + c1 + d1 + e1 + f1 + g1 }),
                          applicative.pure(a + b + c + d + e + f + g))
        }
        
        property("Map with 8 inputs") <- forAll { (a : Int, b : Int, c : Int, d : Int, e : Int, f : Int, g : Int, h : Int) in
            return eq.eqv(applicative.map(applicative.pure(a), applicative.pure(b), applicative.pure(c), applicative.pure(d), applicative.pure(e), applicative.pure(f), applicative.pure(g), applicative.pure(h), { a1, b1, c1, d1, e1, f1, g1, h1 in a1 + b1 + c1 + d1 + e1 + f1 + g1 + h1 }),
                          applicative.pure(a + b + c + d + e + f + g + h))
        }
        
        property("Map with 9 inputs") <- forAll { (a : Int, b : Int, c : Int, d : Int, e : Int, f : Int, g : Int, h : Int) in
            return eq.eqv(applicative.map(applicative.pure(a), applicative.pure(b), applicative.pure(c), applicative.pure(d), applicative.pure(e), applicative.pure(f), applicative.pure(g), applicative.pure(h), applicative.pure(a), { a1, b1, c1, d1, e1, f1, g1, h1, i1 in a1 + b1 + c1 + d1 + e1 + f1 + g1 + h1 + i1 }),
                          applicative.pure(a + b + c + d + e + f + g + h + a))
        }
    }
}
