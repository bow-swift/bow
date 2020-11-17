import Bow
import SwiftCheck

// MARK: Instance of Arbitrary for Exists

extension Exists: Arbitrary where F: ArbitraryK {
    public static var arbitrary: Gen<Exists<F>> {
        Gen.one(of: [
            KindOf<F, Int>.arbitrary.map { Exists($0.value) },
            KindOf<F, String>.arbitrary.map { Exists($0.value) },
            KindOf<F, Function0<Int>>.arbitrary.map { Exists($0.value) },
            KindOf<F, Function0<String>>.arbitrary.map { Exists($0.value) },
            KindOf<F, Function1<Int, Int>>.arbitrary.map { Exists($0.value) },
            KindOf<F, ArrayK<Int>>.arbitrary.map { Exists($0.value) },
            KindOf<F, Option<Int>>.arbitrary.map { Exists($0.value) },
        ])
    }
}
