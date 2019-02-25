import Foundation

public protocol MonadReader: Monad {
    associatedtype D
    
    static func ask() -> Kind<Self, D>
    static func local<A>(_ fa: Kind<Self, A>, _ f: @escaping (D) -> D) -> Kind<Self, A>
}

public extension MonadReader {
    public static func reader<A>(_ f: @escaping (D) -> A) -> Kind<Self, A> {
        return map(ask(), f)
    }
}

// MARK: Syntax for MonadReader

public extension Kind where F: MonadReader {
    public static func ask() -> Kind<F, F.D> {
        return F.ask()
    }

    public func local(_ f: @escaping (F.D) -> F.D) -> Kind<F, A> {
        return F.local(self, f)
    }

    public static func reader(_ f: @escaping (F.D) -> A) -> Kind<F, A> {
        return F.reader(f)
    }
}
