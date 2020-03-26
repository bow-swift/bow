import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Ior: Arbitrary where A: Arbitrary, B: Arbitrary {
    public static var arbitrary: Gen<Ior<A, B>> {
        let left = A.arbitrary.map(Ior.left)
        let right = B.arbitrary.map(Ior.right)
        let both = Gen.zip(A.arbitrary, B.arbitrary).map(Ior.both)
        return Gen.one(of: [left, right, both])
    }
}

// MARK: Instance of ArbitraryK for Ior

extension IorPartial: ArbitraryK where L: Arbitrary {
    public static func generate<A: Arbitrary>() -> IorOf<L, A> {
        Ior.arbitrary.generate
    }
}
