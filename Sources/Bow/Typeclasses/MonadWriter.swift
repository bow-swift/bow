import Foundation

public protocol MonadWriter : Monad {
    associatedtype W
    
    func writer<A>(_ aw : (W, A)) -> Kind<F, A>
    func listen<A>(_ fa : Kind<F, A>) -> Kind<F, (W, A)>
    func pass<A>(_ fa : Kind<F, ((W) -> W, A)>) -> Kind<F, A>
}

public extension MonadWriter {
    public func tell(_ w : W) -> Kind<F, ()> {
        return self.writer((w, ()))
    }
    
    public func listens<A, B>(_ fa : Kind<F, A>, _ f : @escaping (W) -> B) -> Kind<F, (B, A)> {
        return map(self.listen(fa), { pair in (f(pair.0), pair.1) })
    }
    
    public func censor<A>(_ fa : Kind<F, A>, _ f : @escaping (W) -> W) -> Kind<F, A> {
        return self.flatMap(self.listen(fa), { pair in self.writer((f(pair.0), pair.1)) })
    }
}
