import Bow
import SwiftCheck

public protocol ArbitraryK {
    static func generate<A: Arbitrary>() -> Kind<Self, A>
}

public struct KindOf<F, A>: Arbitrary where F: ArbitraryK, A: Arbitrary {
    public static var arbitrary: Gen<KindOf<F, A>> {
        Gen.from { KindOf(F.generate()) }
    }
    
    public let value: Kind<F, A>
    
    public init(_ value: Kind<F, A>) {
        self.value = value
    }
}

extension Gen {
    static func from(_ generator: @escaping () -> A) -> Gen<A> {
        Gen<Void>.pure(()).map(generator)
    }
}
