import Foundation

public protocol MonoidK: SemigroupK {
    static func emptyK<A>() -> Kind<Self, A>
}

/*
public extension MonoidK {
    static func algebra<B>() -> MonoidAlgebra<Self, B> {
        return MonoidAlgebra(combineK: combineK)
    }
}

public class MonoidAlgebra<F: MonoidK, B>: SemigroupAlgebra<F, B>, Monoid {
    public static var empty: MonoidAlgebra<F, B>

    public static var empty: Kind<F, B> {
        return F.emptyK()
    }
}
*/
