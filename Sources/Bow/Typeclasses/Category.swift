import Foundation

public protocol Category {
    associatedtype F
    
    func id<A>() -> Kind2<F, A, A>
    
    func compose<A, B, C>(_ fbc : Kind2<F, B, C>, _ fab : Kind2<F, A, B>) -> Kind2<F, A, C>
}

public extension Category {
    public func andThen<A, B, C>(_ fab : Kind2<F, A, B>, _ fbc : Kind2<F, B, C>) -> Kind2<F, A, C> {
        return self.compose(fbc, fab)
    }
}
