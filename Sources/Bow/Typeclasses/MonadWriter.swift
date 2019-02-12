import Foundation

public protocol MonadWriter : Monad {
    associatedtype W
    
    static func writer<A>(_ aw: (W, A)) -> Kind<Self, A>
    static func listen<A>(_ fa: Kind<Self, A>) -> Kind<Self, (W, A)>
    static func pass<A>(_ fa: Kind<Self, ((W) -> W, A)>) -> Kind<Self, A>
}

public extension MonadWriter {
    public static func tell(_ w: W) -> Kind<Self, ()> {
        return writer((w, ()))
    }
    
    public static func listens<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (W) -> B) -> Kind<Self, (B, A)> {
        return map(listen(fa), { pair in (f(pair.0), pair.1) })
    }
    
    public static func censor<A>(_ fa: Kind<Self, A>, _ f: @escaping (W) -> W) -> Kind<Self, A> {
        return self.flatMap(self.listen(fa), { pair in writer((f(pair.0), pair.1)) })
    }
}

// MARK: Syntax for MonadWriter

public extension Kind where F: MonadWriter {
    public static func writer(_ aw: (F.W, A)) -> Kind<F, A> {
        return F.writer(aw)
    }

    public func listen() -> Kind<F, (F.W, A)> {
        return F.listen(self)
    }

    public static func pass(_ fa: Kind<F, ((F.W) -> F.W, A)>) -> Kind<F, A> {
        return F.pass(fa)
    }

    public static func tell(_ w: F.W) -> Kind<F, ()> {
        return F.tell(w)
    }

    public func listens<B>(_ f: @escaping (F.W) -> B) -> Kind<F, (B, A)> {
        return F.listens(self, f)
    }

    public func censor(_ f: @escaping (F.W) -> F.W) -> Kind<F, A> {
        return F.censor(self, f)
    }
}
