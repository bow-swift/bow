import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension ArrayK: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<ArrayK<A>> {
        Array.arbitrary.map(ArrayK.init)
    }
}

// MARK: Instance of ArbitraryK for ArrayK

extension ArrayKPartial: ArbitraryK {
    public static func generate<A: Arbitrary>() -> ArrayKOf<A> {
        ArrayK.arbitrary.generate
    }
}
