import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Either: Arbitrary where A: Arbitrary, B: Arbitrary {
    public static var arbitrary: Gen<Either<A, B>> {
        let left = A.arbitrary.map(Either<A, B>.left)
        let right = B.arbitrary.map(Either<A, B>.right)
        return Gen.one(of: [left, right])
    }
}
