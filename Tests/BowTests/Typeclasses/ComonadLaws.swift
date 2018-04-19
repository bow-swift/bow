import Foundation
import SwiftCheck
@testable import Bow

class ComonadLaws<F> {
    
    static func check<Comon, EqF>(comonad : Comon, generator : @escaping (Int) -> Kind<F, Int>, eq : EqF) where Comon : Comonad, Comon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        duplicateThenExtractIsId(comonad, generator, eq)
        duplicateThenMapExtractIsId(comonad, generator, eq)
        mapAndCoflatMapCoherence(comonad, generator, eq)
        leftIdentity(comonad, generator, eq)
        rightIdentity(comonad, generator, eq)
        cokleisliLeftIdentity(comonad, generator, eq)
        cokleisliRightIdentity(comonad, generator, eq)
    }
    
    private static func duplicateThenExtractIsId<Comon, EqF>(_ comonad : Comon, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqF) where Comon : Comonad, Comon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Duplicate then extract is equivalent to id") <- forAll { (a : Int) in
            let fa = generator(a)
            return eq.eqv(comonad.extract(comonad.duplicate(fa)),
                          fa)
        }
    }
    
    private static func duplicateThenMapExtractIsId<Comon, EqF>(_ comonad : Comon, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqF) where Comon : Comonad, Comon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Duplicate then map extract is equivalent to id") <- forAll { (a : Int) in
            let fa = generator(a)
            return eq.eqv(comonad.map(comonad.duplicate(fa), comonad.extract),
                          fa)
        }
    }
    
    private static func mapAndCoflatMapCoherence<Comon, EqF>(_ comonad : Comon, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqF) where Comon : Comonad, Comon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("map and coflatMap coherence") <- forAll { (a : Int, b : Int) in
            let fa = generator(a)
            let f = { (_ : Int) in b }
            return eq.eqv(comonad.map(fa, f),
                          comonad.coflatMap(fa, { a in f(comonad.extract(a)) }))
        }
    }
    
    private static func leftIdentity<Comon, EqF>(_ comonad : Comon, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqF) where Comon : Comonad, Comon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Left identity") <- forAll { (a : Int) in
            let fa = generator(a)
            return eq.eqv(comonad.coflatMap(fa, comonad.extract),
                          fa)
        }
    }
    
    private static func rightIdentity<Comon, EqF>(_ comonad : Comon, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqF) where Comon : Comonad, Comon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Right identity") <- forAll { (a : Int, b : Int) in
            let fa = generator(a)
            let f = { (_ : Kind<F, Int>) in generator(b) }
            return eq.eqv(comonad.extract(comonad.coflatMap(fa, f)),
                          f(fa))
        }
    }
    
    private static func cokleisliLeftIdentity<Comon, EqF>(_ comonad : Comon, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqF) where Comon : Comonad, Comon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Cokleisli left identity") <- forAll { (a : Int, b : Int) in
            let fa = generator(a)
            let f = { (_ : Kind<F, Int>) in generator(b) }
            return eq.eqv(Cokleisli(comonad.extract).andThen(Cokleisli(f), comonad).run(fa),
                          f(fa))
        }
    }
    
    private static func cokleisliRightIdentity<Comon, EqF>(_ comonad : Comon, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqF) where Comon : Comonad, Comon.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Cokleisli right identity") <- forAll { (a : Int, b : Int) in
            let fa = generator(a)
            let f = { (_ : Kind<F, Int>) in generator(b) }
            return eq.eqv(Cokleisli(f).andThen(Cokleisli(comonad.extract), comonad).run(fa),
                          f(fa))
        }
    }
}
