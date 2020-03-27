import SwiftCheck
import Bow

public class EquatableLaws<A: Equatable & Arbitrary> {
    public static func check() {
        identity()
        commutativity()
        transitivity()
    }

    private static func identity() {
        property("Identity: Every object is equal to itself") <~ forAll { (a: A) in
            
            a == a
        }
    }

    private static func commutativity() {
        property("Equality is commutative") <~ forAll { (a: A, b: A) in
            
            (a == b)
                ==
            (b == a)
        }
    }
    
    private static func transitivity() {
        property("Equality is transitive") <~ forAll { (a: A, b: A, c: A) in
            
            // (a == b) && (b == c) --> (a == c)
            not((a == b) && (b == c)) || (a == c)
        }
    }
}
