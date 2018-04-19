import Foundation
import SwiftCheck
@testable import Bow

class OrderLaws<F, A> where A : Arbitrary {
    
    static func check<Ord>(order : Ord, generator : @escaping (A) -> F) where Ord : Order, Ord.A == F {
        reflexivityOfLessThanOrEqual(order, generator)
        antisymmetryOfLessThanOrEqual(order, generator)
        transitivityOfLessThanOrEqual(order, generator)
        
        antireflexivityOfLessThan(order, generator)
        asymmetryOfLessThan(order, generator)
        transitivityOfLessThan(order, generator)
        
        reflexivityOfGreaterThanOrEqual(order, generator)
        antisymmetryOfGreaterThanOrEqual(order, generator)
        transitivityOfGreaterThanOrEqual(order, generator)
        
        antireflexivityOfGreaterThan(order, generator)
        asymmetryOfGreaterThan(order, generator)
        transitivityOfGreaterThan(order, generator)
    }
    
    private static func reflexivityOfLessThanOrEqual<Ord>(_ order : Ord, _ generator : @escaping (A) -> F) where Ord : Order, Ord.A == F {
        property("Reflexivity of <=") <- forAll { (a : A) in
            let x = generator(a)
            return order.lte(x, x)
        }
    }
    
    private static func antisymmetryOfLessThanOrEqual<Ord>(_ order : Ord, _ generator : @escaping (A) -> F) where Ord : Order, Ord.A == F {
        property("Antisymetry of <=") <- forAll { (a : A, b : A) in
            let x = generator(a)
            let y = generator(b)
            return (order.lte(x, y) && order.lte(y, x) && order.eqv(x, y)) || order.neqv(x, y)
        }
    }
    
    private static func transitivityOfLessThanOrEqual<Ord>(_ order : Ord, _ generator : @escaping (A) -> F) where Ord : Order, Ord.A == F {
        property("Transitivity of <=") <- forAll { (a : A, b : A, c : A) in
            let x = generator(a)
            let y = generator(b)
            let z = generator(c)
            
            return !(order.lte(x, y) && order.lte(y, z)) || order.lte(x, z)
        }
    }
    
    private static func antireflexivityOfLessThan<Ord>(_ order : Ord, _ generator : @escaping (A) -> F) where Ord : Order, Ord.A == F {
        property("Antireflexivity of <") <- forAll { (a : A) in
            let x = generator(a)
            return !order.lt(x, x)
        }
    }
    
    private static func asymmetryOfLessThan<Ord>(_ order : Ord, _ generator : @escaping (A) -> F) where Ord : Order, Ord.A == F {
        property("Asymmetry of <") <- forAll { (a : A, b : A) in
            let x = generator(a)
            let y = generator(b)
            return xor(order.lt(x, y), order.lt(y, x)) || order.eqv(x, y)
        }
    }
    
    private static func transitivityOfLessThan<Ord>(_ order : Ord, _ generator : @escaping (A) -> F) where Ord : Order, Ord.A == F {
        property("Transitivity of <") <- forAll { (a : A, b : A, c : A) in
            let x = generator(a)
            let y = generator(b)
            let z = generator(c)
            
            return !(order.lt(x, y) && order.lt(y, z)) || order.lt(x, z)
        }
    }
    
    private static func reflexivityOfGreaterThanOrEqual<Ord>(_ order : Ord, _ generator : @escaping (A) -> F) where Ord : Order, Ord.A == F {
        property("Reflexivity of >=") <- forAll { (a : A) in
            let x = generator(a)
            return order.gte(x, x)
        }
    }
    
    private static func antisymmetryOfGreaterThanOrEqual<Ord>(_ order : Ord, _ generator : @escaping (A) -> F) where Ord : Order, Ord.A == F {
        property("Antisymetry of >=") <- forAll { (a : A, b : A) in
            let x = generator(a)
            let y = generator(b)
            return (order.gte(x, y) && order.gte(y, x) && order.eqv(x, y)) || order.neqv(x, y)
        }
    }
    
    private static func transitivityOfGreaterThanOrEqual<Ord>(_ order : Ord, _ generator : @escaping (A) -> F) where Ord : Order, Ord.A == F {
        property("Transitivity of >=") <- forAll { (a : A, b : A, c : A) in
            let x = generator(a)
            let y = generator(b)
            let z = generator(c)
            
            return !(order.gte(x, y) && order.gte(y, z)) || order.gte(x, z)
        }
    }
    
    private static func antireflexivityOfGreaterThan<Ord>(_ order : Ord, _ generator : @escaping (A) -> F) where Ord : Order, Ord.A == F {
        property("Antireflexivity of >") <- forAll { (a : A) in
            let x = generator(a)
            return !order.gt(x, x)
        }
    }
    
    private static func asymmetryOfGreaterThan<Ord>(_ order : Ord, _ generator : @escaping (A) -> F) where Ord : Order, Ord.A == F {
        property("Asymmetry of >") <- forAll { (a : A, b : A) in
            let x = generator(a)
            let y = generator(b)
            return xor(order.gt(x, y), order.gt(y, x)) || order.eqv(x, y)
        }
    }
    
    private static func transitivityOfGreaterThan<Ord>(_ order : Ord, _ generator : @escaping (A) -> F) where Ord : Order, Ord.A == F {
        property("Transitivity of >") <- forAll { (a : A, b : A, c : A) in
            let x = generator(a)
            let y = generator(b)
            let z = generator(c)
            
            return !(order.gt(x, y) && order.gt(y, z)) || order.gt(x, z)
        }
    }
    
}
