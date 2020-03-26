import SwiftCheck
import Bow

public class ComparableLaws<A: Comparable & Arbitrary> {
    
    public static func check() {
        reflexivityOfLessThanOrEqual()
        antisymmetryOfLessThanOrEqual()
        transitivityOfLessThanOrEqual()
        
        antireflexivityOfLessThan()
        asymmetryOfLessThan()
        transitivityOfLessThan()
        
        reflexivityOfGreaterThanOrEqual()
        antisymmetryOfGreaterThanOrEqual()
        transitivityOfGreaterThanOrEqual()
        
        antireflexivityOfGreaterThan()
        asymmetryOfGreaterThan()
        transitivityOfGreaterThan()
        
        sortConsistentWithMaxMin()
    }
    
    private static func reflexivityOfLessThanOrEqual() {
        property("Reflexivity of <=") <~ forAll { (x: A) in
            x <= x
        }
    }
    
    private static func antisymmetryOfLessThanOrEqual() {
        property("Antisymetry of <=") <~ forAll { (x: A, y: A) in
            (x <= y && y <= x && x == y) || x != y
        }
    }
    
    private static func transitivityOfLessThanOrEqual() {
        property("Transitivity of <=") <~ forAll { (x: A, y: A, z: A) in
            !(x <= y && y <= z) || x <= z
        }
    }
    
    private static func antireflexivityOfLessThan() {
        property("Antireflexivity of <") <~ forAll { (x: A) in
            !(x < x)
        }
    }
    
    private static func asymmetryOfLessThan() {
        property("Asymmetry of <") <~ forAll { (x: A, y: A) in
            xor(x < y, y < x) || x == y
        }
    }
    
    private static func transitivityOfLessThan() {
        property("Transitivity of <") <~ forAll { (x: A, y: A, z: A) in
            !(x < y && y < z) || x < z
        }
    }
    
    private static func reflexivityOfGreaterThanOrEqual() {
        property("Reflexivity of >=") <~ forAll { (x: A) in
            x >= x
        }
    }
    
    private static func antisymmetryOfGreaterThanOrEqual() {
        property("Antisymetry of >=") <~ forAll { (x: A, y: A) in
            (x >= y && y >= x && x == y) || x != y
        }
    }
    
    private static func transitivityOfGreaterThanOrEqual() {
        property("Transitivity of >=") <~ forAll { (x: A, y: A, z: A) in
            !(x >= y && y >= z) || x >= z
        }
    }
    
    private static func antireflexivityOfGreaterThan() {
        property("Antireflexivity of >") <~ forAll { (x: A) in
            !(x > x)
        }
    }
    
    private static func asymmetryOfGreaterThan() {
        property("Asymmetry of >") <~ forAll { (x: A, y: A) in
            xor(x > y, y > x) || x == y
        }
    }
    
    private static func transitivityOfGreaterThan() {
        property("Transitivity of >") <~ forAll { (x: A, y: A, z: A) in
            !(x > y && y > z) || x > z
        }
    }
    
    private static func sortConsistentWithMaxMin() {
        property("Sort is consistent with max and min") <~ forAll { (x: A, y: A) in
            let sorted = A.sort(x, y)
            return sorted.0 == A.max(x, y) && sorted.1 == A.min(x, y)
        }
    }
}
