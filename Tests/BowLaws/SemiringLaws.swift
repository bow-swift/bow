import Bow
import SwiftCheck

public class SemiringLaws<A: Semiring & Equatable & Arbitrary> {
    public static func check() {
        MonoidLaws<A>.check()
        commutativityForCombining()
        associativityForMultiplying()
        leftIdentityForMultiplying()
        rightIdentityForMultiplying()
        leftDistribution()
        rightDistribution()
        leftAnnihilation()
        rightAnnihilation()
    }
    
    private static func commutativityForCombining() {
        property("Commutativity for combining") <~ forAll { (a: A) in
            return A.zero().combine(a) == a.combine(.zero())
        }
    }
    
    private static func associativityForMultiplying() {
        property("Ascociativity for multiplying") <~ forAll { (a: A, b: A, c: A) in
            return (a.multiply(b)).multiply(c) == a.multiply(b.multiply(c))
        }
    }
    
    private static func leftIdentityForMultiplying() {
        property("Left identity for multiplying") <~ forAll { (a: A) in
            return A.one().multiply(a) == a
        }
    }
    
    private static func rightIdentityForMultiplying() {
        property("Right identity for multiplying") <~ forAll { (a: A) in
            return a.multiply(.one()) == a
        }
    }
    
    private static func leftDistribution() {
        property("Left distribution") <~ forAll { (a: A, b: A, c: A) in
            return a.multiply(b.combine(c)) == (a.multiply(b)).combine(a.multiply(c))
       }
    }
    
    private static func rightDistribution() {
        property("Right distribution") <~ forAll { (a: A, b: A, c: A) in
            return (a.combine(b)).multiply(c) == (a.multiply(c)).combine(b.multiply(c))
       }
    }

    private static func leftAnnihilation() {
        property("Left Annihilation") <~ forAll { (a: A) in
            return A.zero().multiply(a) == .zero()
       }
    }
    
    private static func rightAnnihilation() {
        property("Right Annihilation") <~ forAll { (a: A) in
            return a.multiply(.zero()) == .zero()
       }
    }
}
