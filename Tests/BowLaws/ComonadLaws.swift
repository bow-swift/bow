import Foundation
import SwiftCheck
@testable import Bow

class ComonadLaws<F: Comonad & EquatableK> {
    
    static func check(generator: @escaping (Int) -> Kind<F, Int>) {
        duplicateThenExtractIsId(generator)
        duplicateThenMapExtractIsId(generator)
        mapAndCoflatMapCoherence(generator)
        leftIdentity(generator)
        rightIdentity(generator)
        cokleisliLeftIdentity(generator)
        cokleisliRightIdentity(generator)
    }
    
    private static func duplicateThenExtractIsId(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Duplicate then extract is equivalent to id") <- forAll { (a: Int) in
            let fa = generator(a)
            return F.extract(F.duplicate(fa)) == fa
        }
    }
    
    private static func duplicateThenMapExtractIsId(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Duplicate then map extract is equivalent to id") <- forAll { (a: Int) in
            let fa = generator(a)
            return F.map(F.duplicate(fa), F.extract) == fa
        }
    }
    
    private static func mapAndCoflatMapCoherence(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("map and coflatMap coherence") <- forAll { (a: Int, f: ArrowOf<Int, Int>) in
            let fa = generator(a)
            return F.map(fa, f.getArrow) == F.coflatMap(fa, { a in f.getArrow(F.extract(a)) })
        }
    }
    
    private static func leftIdentity(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Left identity") <- forAll { (a: Int) in
            let fa = generator(a)
            return F.coflatMap(fa, F.extract) == fa
        }
    }
    
    private static func rightIdentity(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Right identity") <- forAll { (a: Int, b: Int) in
            let fa = generator(a)
            let f = { (_ : Kind<F, Int>) in generator(b) }
            return F.extract(F.coflatMap(fa, f)) == f(fa)
        }
    }
    
    private static func cokleisliLeftIdentity(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Cokleisli left identity") <- forAll { (a: Int, b: Int) in
            let fa = generator(a)
            let f = { (_: Kind<F, Int>) in generator(b) }
            return Cokleisli(F.extract).andThen(Cokleisli(f)).run(fa) == f(fa)
        }
    }
    
    private static func cokleisliRightIdentity(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Cokleisli right identity") <- forAll { (a: Int, b: Int) in
            let fa = generator(a)
            let f = { (_: Kind<F, Int>) in generator(b) }
            return Cokleisli(f).andThen(Cokleisli(F.extract)).run(fa) == f(fa)
        }
    }
}
