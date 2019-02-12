import Foundation

public protocol MonadError: Monad, ApplicativeError {}

public extension MonadError {
    public static func ensure<A>(_ fa: Kind<Self, A>, _ error: @escaping () -> E, _ predicate: @escaping (A) -> Bool) -> Kind<Self, A> {
        return flatMap(fa, { a in
            predicate(a) ? pure(a) : raiseError(error())
        })
    }
}

// MARK Syntax for MonadError

public extension Kind where F: MonadError {
    public func ensure(_ error: @escaping () -> F.E, _ predicate: @escaping (A) -> Bool) -> Kind<F, A> {
        return F.ensure(self, error, predicate)
    }
}
