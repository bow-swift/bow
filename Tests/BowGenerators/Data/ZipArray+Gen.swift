@testable import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension ZipArray: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<ZipArray<A>> {
        return Gen<ZipArray<A>>.one(of: [
            Array<A>.arbitrary.map { ZipArray(ZipArray.Data.finite($0)) },
            NonEmptyArray<A>.arbitrary.map { ZipArray(ZipArray.Data.infinite($0)) }
        ])
    }
}

// MARK: Instance of `ArbitraryK` for `ZipArray`

extension ForZipArray: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<ForZipArray, A> {
        return ZipArray.arbitrary.generate
    }
}
