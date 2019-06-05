import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Const: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<Const<A, T>> {
        return A.arbitrary.map(Const.init)
    }
}
