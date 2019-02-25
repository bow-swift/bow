import Foundation
import SwiftCheck
@testable import Bow

class SemigroupKLaws<F: SemigroupK & EquatableK> {
    
    static func check(generator : @escaping (Int) -> Kind<F, Int>) {
        associative(generator)
    }
    
    private static func associative(_ generator : @escaping (Int) -> Kind<F, Int>) {
        property("SemigroupK combine is associative") <- forAll { (a: Int, b: Int, c: Int) in
            let fa = generator(a)
            let fb = generator(b)
            let fc = generator(c)
            return fa.combineK(fb.combineK(fc)) == fa.combineK(fb).combineK(fc)
        }
    }
}
