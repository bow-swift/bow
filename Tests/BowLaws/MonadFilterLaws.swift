import Foundation
import SwiftCheck
@testable import Bow

class MonadFilterLaws<F: MonadFilter & EquatableK> {
    
    static func check(generator : @escaping (Int) -> Kind<F, Int>) {
        leftEmpty(generator)
        rightEmpty(generator)
        consistency(generator)
    }
    
    private static func leftEmpty(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Left empty") <- forAll { (_ : Int) in
            return F.flatMap(F.empty(), generator) == F.empty()
        }
    }
    
    private static func rightEmpty(_ generator : @escaping (Int) -> Kind<F, Int>) {
        property("Right empty") <- forAll { (a : Int) in
            let fa = generator(a)
            return F.flatMap(fa, constant(F.empty())) == F.empty() as Kind<F, Int>
        }
    }
    
    private static func consistency(_ generator : @escaping (Int) -> Kind<F, Int>)  {
        property("Consistency") <- forAll { (a : Int, f : ArrowOf<Int, Bool>) in
            let fa = generator(a)
            return F.filter(fa, f.getArrow) == F.flatMap(fa, { a in f.getArrow(a) ? F.pure(a) : F.empty() })
        }
    }
}
