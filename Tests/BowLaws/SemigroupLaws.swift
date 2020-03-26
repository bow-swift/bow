import SwiftCheck
import Bow

public class SemigroupLaws<A: Semigroup & Arbitrary & Equatable> {
    public static func check() {
        associativity()
        reduction()
    }
    
    private static func associativity() {
        property("Associativity") <~ forAll { (a: A, b: A, c: A) in
            a.combine(b).combine(c)
                ==
            a.combine(b.combine(c))
        }
    }
    
    private static func reduction() {
        property("Reduction") <~ forAll { (a: A, b: A, c: A) in
            A.combineAll(a, b, c)
                ==
            a.combine(b).combine(c)
        }
    }
}
