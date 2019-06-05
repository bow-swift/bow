import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension ArrayK: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<ArrayK<A>> {
        return Array.arbitrary.map(ArrayK.init)
    }
}
