import Bow
import SwiftCheck

public protocol ArbitraryK {
    static func generate<A: Arbitrary>() -> KindOf<Self, A>
}

public struct KindOf<F, A>: Arbitrary where F: ArbitraryK, A: Arbitrary {
    public static var arbitrary: Gen<KindOf<F, A>> {
        return Gen.pure(()).map { _ in F.generate() as KindOf<F, A> }
    }
    
    public let value: Kind<F, A>
    
    public init(value: Kind<F, A>) {
        self.value = value
    }
}
