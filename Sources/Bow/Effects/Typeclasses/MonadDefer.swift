import Foundation

public protocol MonadDefer : MonadError where E == Error {
    func deferExecution<A>(_ fa : @escaping () -> Kind<F, A>) -> Kind<F, A>
}

public extension MonadDefer {
    public func invoke<A>(_ f : @escaping () throws -> A) -> Kind<F, A> {
        return self.deferExecution {
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
    
    public func deferUnsafe<A>(_ f : @escaping () -> Either<Error, A>) -> Kind<F, A> {
        return self.deferExecution { f().fold({ e in self.raiseError(e) },
                                              { a in self.pure(a) }) }
    }
}
