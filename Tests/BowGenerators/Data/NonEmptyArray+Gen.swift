import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension NonEmptyArray: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<NonEmptyArray<A>> {
        return Array.arbitrary
            .suchThat { array in array.count > 0 }
            .map(NonEmptyArray.fromArrayUnsafe)
    }
}
