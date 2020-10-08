import Foundation
import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing
extension Tree: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<Tree<A>> {
        Gen.sized { gen(size: UInt($0)) }
    }

    private static func gen(size: UInt) -> Gen<Tree<A>> {
        let subForests = (size > 0)
            ? (size-1).arbitratyPartition.flatMap { SwiftCheck.sequence($0.map(gen)) }
            : .pure([])
        return Gen.zip(A.arbitrary, subForests)
            .map(Tree.init)
    }
}

// MARK: Instance of ArbitraryK for Tree
extension TreePartial: ArbitraryK {
    public static func generate<A: Arbitrary>() -> TreeOf<A> {
        Tree.arbitrary.generate
    }
}

extension UInt {

    /// Generates an integer partition of self, i.e. a list of
    /// integers whose sum is equal to self.
    var arbitratyPartition: Gen<[UInt]> {
        // To generate a partition, we generate a random number i1 smaller or equal than self. If i1 is smaller, we generate
        // a new number i2 that is smaller or equal than self-i1.
        // We continue the process until the sum of the generated numbers
        // is equal to self.

        /// Generate a random number smaller than `n`, appends it to the list and adds it to the sum.
        func f(_ n: UInt, _ list: [UInt], _ listSum: UInt) -> Gen<([UInt], UInt)> {
            guard n > 0 else { return .pure((list, listSum))}
            return Gen.fromElements(in: 1...n).flatMap { i in
                .pure((list + [i], listSum + i))
            }
        }

        // Recursively adds an integer to the list to construct a partition
        // of self.
        func g(_ list: [UInt], _ listSum: UInt) -> Gen<[UInt]> {
            let remaining = self - listSum
            if remaining > 0 {
                return f(remaining, list, listSum).flatMap(g)
            } else {
                return .pure(list)
            }
        }

        return f(self, [], 0).flatMap(g)
    }
}
