import Foundation
import SwiftCheck
@testable import Bow

class EquatableKLaws<F: EquatableK, A: Arbitrary & Equatable> {
    
    static func check(generator: @escaping (A) -> Kind<F, A>) {
        identityInEquality(generator: generator)
        commutativityInEquality(generator: generator)
    }
    
    private static func identityInEquality(generator: @escaping (A) -> Kind<F, A>) {
        property("Identity: Every object is equal to itself") <- forAll() { (a : A) in
            let fa = generator(a)
            return fa == fa
        }
    }
    
    private static func commutativityInEquality(generator: @escaping (A) -> Kind<F, A>) {
        property("Equality is commutative") <- forAll() { (a : A, b : A) in
            let fa = generator(a)
            let fb = generator(b)
            return (fa == fb) == (fb == fa)
        }
    }
}
