import Foundation
@testable import Bow

class MonoidLaws<A: Monoid & Equatable> {
    
    static func check(a: A) -> Bool {
        return leftIdentity(a) && rightIdentity(a)
    }
    
    private static func leftIdentity(_ a: A) -> Bool {
        return A.empty().combine(a) == a
    }
    
    private static func rightIdentity(_ a: A) -> Bool {
        return a.combine(A.empty()) == a
    }
}
