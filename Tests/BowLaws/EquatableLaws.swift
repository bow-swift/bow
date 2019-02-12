import Foundation
import SwiftCheck
@testable import Bow

class EquatableLaws<A: Equatable & Arbitrary> {
    static func check() {
        identityInEquality()
        commutativityInEquality()
    }

    private static func identityInEquality() {
        property("Identity: Every object is equal to itself") <- forAll() { (a: A) in
            return a == a
        }
    }

    private static func commutativityInEquality() {
        property("Equality is commutative") <- forAll() { (a: A, b: A) in
            return (a == b) == (b == a)
        }
    }
}
