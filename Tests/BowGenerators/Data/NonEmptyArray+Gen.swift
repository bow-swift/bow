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

// MARK: Instance of `ArbitraryK` for `NonEmptyArray`

extension ForNonEmptyArray: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<ForNonEmptyArray, A> {
        return NonEmptyArray.arbitrary.generate
    }
}
