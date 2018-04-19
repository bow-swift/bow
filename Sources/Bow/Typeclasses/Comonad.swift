import Foundation

public protocol Comonad : Functor {
    func coflatMap<A, B>(_ fa : Kind<F, A>, _ f : @escaping (Kind<F, A>) -> B) -> Kind<F, B>
    func extract<A>(_ fa : Kind<F, A>) -> A
}

public extension Comonad {
    public func duplicate<A>(_ fa : Kind<F, A>) -> Kind<F, Kind<F, A>> {
        return coflatMap(fa, id)
    }
}
