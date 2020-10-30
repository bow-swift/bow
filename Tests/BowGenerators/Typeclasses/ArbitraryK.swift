import Bow
import SwiftCheck

public protocol ArbitraryK {
    static func generate<A: Arbitrary>() -> Kind<Self, A>
}

public struct KindOf<F, A> {
    public let value: Kind<F, A>
    
    public init(_ value: Kind<F, A>) {
        self.value = value
    }
}

extension KindOf: Equatable where F: EquatableK, A: Equatable {}

extension KindOf: Hashable where F: HashableK, A: Hashable {}

extension KindOf: Arbitrary where F: ArbitraryK, A: Arbitrary {
    public static var arbitrary: Gen<KindOf<F, A>> {
        Gen.from { KindOf(F.generate()) }
    }
}

extension KindOf: CoArbitrary where F: Comonad, A: CoArbitrary {
    public static func coarbitrary<C>(_ x : Self) -> ((Gen<C>) -> Gen<C>) {
        A.coarbitrary(x.value.extract())
    }
}

public extension Gen {
    static func from(_ generator: @escaping () -> A) -> Gen<A> {
        Gen<Void>.pure(()).map(generator)
    }
}
