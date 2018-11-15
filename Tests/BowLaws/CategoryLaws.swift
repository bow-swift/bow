import Foundation
import SwiftCheck
@testable import Bow

class CategoryLaws<F> {
    static func check<Cat, EqInt>(category : Cat, generator : @escaping (Int) -> Kind2<F, Int, Int>, eq : EqInt)
        where Cat : Bow.Category, Cat.F == F, EqInt : Eq, EqInt.A == Kind2<F, Int, Int> {
            leftIdentity(category, generator, eq)
            rightIdentity(category, generator, eq)
            composition(category, generator, eq)
    }
    
    private static func leftIdentity<Cat, EqInt>(_ category : Cat, _ generator : @escaping (Int) -> Kind2<F, Int, Int>, _ eq : EqInt)
        where Cat : Bow.Category, Cat.F == F, EqInt : Eq, EqInt.A == Kind2<F, Int, Int> {
            property("Left identity") <- forAll { (a : Int) in
                let fa = generator(a)
                return eq.eqv(category.compose(fa, category.id()), fa)
            }
    }
    
    private static func rightIdentity<Cat, EqInt>(_ category : Cat, _ generator : @escaping (Int) -> Kind2<F, Int, Int>, _ eq : EqInt)
        where Cat : Bow.Category, Cat.F == F, EqInt : Eq, EqInt.A == Kind2<F, Int, Int> {
            property("Right identity") <- forAll { (a : Int) in
                let fa = generator(a)
                return eq.eqv(category.compose(category.id(), fa), fa)
            }
    }
    
    private static func composition<Cat, EqInt>(_ category : Cat, _ generator : @escaping (Int) -> Kind2<F, Int, Int>, _ eq : EqInt)
        where Cat : Bow.Category, Cat.F == F, EqInt : Eq, EqInt.A == Kind2<F, Int, Int> {
            property("Composition") <- forAll { (a : Int, b : Int, c : Int) in
                let fa = generator(a)
                let fb = generator(b)
                let fc = generator(c)
                return eq.eqv(category.compose(category.compose(fa, fb), fc),
                              category.compose(fa, category.compose(fb, fc)))
            }
    }
}
