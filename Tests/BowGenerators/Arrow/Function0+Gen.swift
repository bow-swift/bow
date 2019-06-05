import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Function0: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<Function0<A>> {
        return A.arbitrary.map { a in Function0 { a } }
    }
}
