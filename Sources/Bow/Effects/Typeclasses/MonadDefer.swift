import Foundation

public protocol MonadDefer : MonadError where E == Error {
    func delay<A>(_ fa : @escaping () -> Kind<F, A>) -> Kind<F, A>
}

public extension MonadDefer {
    public func invoke<A>(_ f : @escaping () throws -> A) -> Kind<F, A> {
        return self.delay {
            do {
                return try self.pure(f())
            } catch {
                return self.raiseError(error)
            }
        }
    }
    
    public func lazy() -> Kind<F, Unit> {
        return invoke {}
    }
    
    public func delayEither<A>(_ f : @escaping () -> Either<Error, A>) -> Kind<F, A> {
        return self.delay { f().fold({ e in self.raiseError(e) },
                                     { a in self.pure(a) }) }
    }
}
