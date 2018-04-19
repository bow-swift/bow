import Foundation

public protocol MonadError : Monad, ApplicativeError {}

public extension MonadError {
    public func ensure<A>(_ fa : Kind<F, A>, error : @escaping () -> E, predicate : @escaping (A) -> Bool) -> Kind<F, A> {
        return flatMap(fa, { a in
            predicate(a) ? self.pure(a) : self.raiseError(error())
        })
    }
}
