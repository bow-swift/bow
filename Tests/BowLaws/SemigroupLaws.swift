import Foundation
import SwiftCheck
@testable import Bow

class SemigroupLaws<A: Semigroup & Equatable> {
    
    static func check(a: A, b: A, c: A) -> Bool {
        return associativity(a, b, c) && reduction(a, b, c)
    }
    
    private static func associativity(_ a: A, _ b: A, _ c: A) -> Bool {
        return a.combine(b).combine(c) == a.combine(b.combine(c))
    }
    
    private static func reduction(_ a: A, _ b: A, _ c: A) -> Bool {
        return A.combineAll(a, b, c) == a.combine(b).combine(c)
    }
}
