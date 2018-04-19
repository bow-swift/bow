import Foundation
import SwiftCheck
@testable import Bow

class FunctorLaws<F> {
    static func check<Func, EqA, EqUnit>(functor : Func, generator : @escaping (Int) -> Kind<F, Int>, eq : EqA, eqUnit : EqUnit) where Func : Functor, Func.F == F, EqA : Eq, EqA.A == Kind<F, Int>, EqUnit : Eq, EqUnit.A == Kind<F, ()> {
        covariantIdentity(functor, generator, eq)
        covariantComposition(functor, generator, eq)
        void(functor, generator, eqUnit)
        fproduct(functor, generator, eq)
        tupleLeft(functor, generator, eq)
        tupleRight(functor, generator, eq)
    }

    private static func covariantIdentity<Func, EqA>(_ functor : Func, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqA) where Func : Functor, Func.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("Identity is preserved under functor transformation") <- forAll() { (a : Int) in
            let fa = generator(a)
            return eq.eqv(functor.map(fa, id), id(fa))
        }
    }
    
    private static func covariantComposition<Func, EqA>(_ functor : Func, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqA) where Func : Functor, Func.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("Composition is preserved under functor transformation") <- forAll() { (a : Int, b : Int, c : Int) in
            let f : (Int) -> Int = constF(b)
            let g : (Int) -> Int = constF(c)
            let fa = generator(a)
            return eq.eqv(functor.map(functor.map(fa, f), g), functor.map(fa, f >>> g))
        }
    }
    
    private static func void<Func, EqA>(_ functor : Func, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqA) where Func : Functor, Func.F == F, EqA : Eq, EqA.A == Kind<F, ()> {
        property("Void") <- forAll() { (a : Int, b : Int) in
            let fa = generator(a)
            let f = { (_ : Int) in b }
            return eq.eqv(functor.void(fa),
                          functor.void(functor.map(fa, f)))
        }
    }
    
    private static func fproduct<Func, EqA>(_ functor : Func, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqA) where Func : Functor, Func.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("fproduct") <- forAll { (a : Int, b : Int) in
            let fa = generator(a)
            let f = { (_ : Int) in b }
            return eq.eqv(functor.map(functor.fproduct(fa, f), { x in x.1 }),
                          functor.map(fa, f))
        }
    }
    
    private static func tupleLeft<Func, EqA>(_ functor : Func, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqA) where Func : Functor, Func.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("tuple left") <- forAll { (a : Int, b : Int) in
            let fa = generator(a)
            return eq.eqv(functor.map(functor.tupleLeft(fa, b), { x in x.0 }),
                          functor.as(fa, b))
        }
    }
    
    private static func tupleRight<Func, EqA>(_ functor : Func, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqA) where Func : Functor, Func.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("tuple right") <- forAll { (a : Int, b : Int) in
            let fa = generator(a)
            return eq.eqv(functor.map(functor.tupleRight(fa, b), { x in x.1 }),
                          functor.as(fa, b))
        }
    }
}
