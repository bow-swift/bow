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
            return (a.times(b)).times(c) == a.times(b.times(c))
        }
    }
    
    private static func leftIdentityForMultiplying() {
        property("Left identity for multiplying") <~ forAll { (a: A) in
            return A.one().times(a) == a
        }
    }
    
    private static func rightIdentityForMultiplying() {
        property("Right identity for multiplying") <~ forAll { (a: A) in
            return a.times(.one()) == a
        }
    }
    
    private static func leftDistribution() {
        property("Left distribution") <~ forAll { (a: A, b: A, c: A) in
            return a.times(b.combine(c)) == (a.times(b)).combine(a.times(c))
       }
    }
    
    private static func rightDistribution() {
        property("Right distribution") <~ forAll { (a: A, b: A, c: A) in
            return (a.combine(b)).times(c) == (a.times(c)).combine(b.times(c))
       }
    }

    private static func leftAnnihilation() {
        property("Left Annihilation") <~ forAll { (a: A) in
            return A.zero().times(a) == .zero()
       }
    }
    
    private static func rightAnnihilation() {
        property("Right Annihilation") <~ forAll { (a: A) in
            return a.times(.zero()) == .zero()
       }
    }
}
