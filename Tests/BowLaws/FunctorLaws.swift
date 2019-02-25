import Foundation
import SwiftCheck
@testable import Bow

class FunctorLaws<F: Functor & EquatableK> {
    static func check(generator: @escaping (Int) -> Kind<F, Int>) {
        InvariantLaws.check(generator: generator)
        covariantIdentity(generator)
        covariantComposition(generator)
        void(generator)
        fproduct(generator)
        tupleLeft(generator)
        tupleRight(generator)
    }

    private static func covariantIdentity(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Identity is preserved under functor transformation") <- forAll() { (a : Int) in
            let fa = generator(a)
            return F.map(fa, id) == id(fa)
        }
    }
    
    private static func covariantComposition(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Composition is preserved under functor transformation") <- forAll() { (a: Int, f: ArrowOf<Int, Int>, g: ArrowOf<Int, Int>) in
            let fa = generator(a)
            return F.map(F.map(fa, f.getArrow), g.getArrow) ==
                F.map(fa, f.getArrow >>> g.getArrow)
        }
    }
    
    private static func void(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Void") <- forAll() { (a: Int, f: ArrowOf<Int, Int>) in
            let fa = generator(a)
            return isEqual(F.void(fa), F.void(F.map(fa, f.getArrow)))
        }
    }
    
    private static func fproduct(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("fproduct") <- forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let fa = generator(a)
            return F.map(F.fproduct(fa, f.getArrow), { x in x.1 }) ==
                F.map(fa, f.getArrow)
        }
    }
    
    private static func tupleLeft(_ generator : @escaping (Int) -> Kind<F, Int>) {
        property("tuple left") <- forAll { (a : Int, b : Int) in
            let fa = generator(a)
            return F.map(F.tupleLeft(fa, b), { x in x.0 }) ==
                F.as(fa, b)
        }
    }
    
    private static func tupleRight(_ generator : @escaping (Int) -> Kind<F, Int>) {
        property("tuple right") <- forAll { (a : Int, b : Int) in
            let fa = generator(a)
            return F.map(F.tupleRight(fa, b), { x in x.1 }) ==
                F.as(fa, b)
        }
    }
}
