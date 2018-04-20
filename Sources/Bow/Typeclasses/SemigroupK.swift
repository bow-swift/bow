import Foundation

public protocol SemigroupK : Typeclass {
    associatedtype F
    
    func combineK<A>(_ x : Kind<F, A>, _ y : Kind<F, A>) -> Kind<F, A>
}

public extension SemigroupK {
    public func algebra<B>() -> SemigroupAlgebra<F, B> {
        return SemigroupAlgebra(combineK : self.combineK)
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
