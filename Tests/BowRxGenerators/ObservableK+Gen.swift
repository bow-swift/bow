import Bow
import BowGenerators
import BowRx
import SwiftCheck

// MARK: Generator for Property-based Testing

extension ObservableK: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<ObservableK<A>> {
        return A.arbitrary.map { x in ObservableK.pure(x)^ }
    }
}

// MARK: Instance of `ArbitraryK` for `ObservableK`

extension ForObservableK: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<ForObservableK, A> {
        return ObservableK.arbitrary.generate
    }
}
