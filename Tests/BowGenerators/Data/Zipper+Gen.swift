import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Zipper: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<Zipper<A>> {
        Gen.zip([A].arbitrary, A.arbitrary, [A].arbitrary)
            .map(Zipper.init(left:focus:right:))
    }
}

// MARK: Instance of ArbitraryK for ArrayK

extension ZipperPartial: ArbitraryK {
    public static func generate<A: Arbitrary>() -> ZipperOf<A> {
        Zipper<A>.arbitrary.generate
    }
}

