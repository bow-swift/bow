import Foundation

public protocol SemigroupK {
    static func combineK<A>(_ x: Kind<Self, A>, _ y: Kind<Self, A>) -> Kind<Self, A>
}

/*
 public extension SemigroupK {
    public static func algebra<B>() -> SemigroupAlgebra<Self, B> {
        return SemigroupAlgebra(combineK: combineK)
    }
}

public class SemigroupAlgebra<F, B> : Semigroup {
    public typealias A = Kind<F, B>
    
    private let combineK : (Kind<F, B>, Kind<F, B>) -> Kind<F, B>
    
    init(combineK : @escaping (Kind<F, B>, Kind<F, B>) -> Kind<F, B>) {
        self.combineK = combineK
    }
    
    public func combine(_ a: Kind<F, B>, _ b: Kind<F, B>) -> Kind<F, B> {
        return combineK(a, b)
    }
}
*/

// MARK: Syntax for SemigroupK

public extension Kind where F: SemigroupK {
    public func combineK(_ y: Kind<F, A>) -> Kind<F, A> {
        return F.combineK(self, y)
    }
}
