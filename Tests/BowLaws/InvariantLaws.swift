import Foundation
import SwiftCheck
@testable import Bow

class InvariantLaws<F: Invariant & EquatableK> {
    static func check(generator: @escaping (Int) -> Kind<F, Int>) {
        self.identity(generator)
        self.composition(generator)
    }
    
    private static func identity(_ generator : @escaping (Int) -> Kind<F, Int>) {
        property("Identity") <- forAll { (a : Int) in
            let fa = generator(a)
            return F.imap(fa, id, id) == fa
        }
    }
    
    private static func composition(_ generator : @escaping (Int) -> Kind<F, Int>) {
        property("Composition") <- forAll { (a: Int, f1: ArrowOf<Int, Int>, f2: ArrowOf<Int, Int>, g1: ArrowOf<Int, Int>, g2: ArrowOf<Int, Int>) in
            let fa = generator(a)
            let left = F.imap(F.imap(fa, f1.getArrow, f2.getArrow), g1.getArrow, g2.getArrow)
            let right = F.imap(fa, g1.getArrow <<< f1.getArrow, f2.getArrow <<< g2.getArrow)
            return left == right
        }
    }
}
