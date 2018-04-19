import Foundation

public protocol MonadReader : Monad {
    associatedtype D
    
    func ask() -> Kind<F, D>
    func local<A>(_ f : @escaping (D) -> D, _ fa : Kind<F, A>) -> Kind<F, A>
}

public extension MonadReader {
    public func reader<A>(_ f : @escaping (D) -> A) -> Kind<F, A> {
        return self.map(ask(), f)
    }
}
