import Foundation
import Bow

public protocol MonadDefer : MonadError where E : Error {
    func suspend<A>(_ fa : @escaping () -> Kind<F, A>) -> Kind<F, A>
}

public extension MonadDefer {
    public func delay<A>(_ f : @escaping () throws -> A) -> Kind<F, A> {
        return self.suspend {
            do {
                return try self.pure(f())
            } catch {
                return self.raiseError(error as! E)
            }
        }
    }
    
    public func lazy() -> Kind<F, ()> {
        return delay {}
    }
    
    public func delayEither<A>(_ f : @escaping () -> Either<Error, A>) -> Kind<F, A> {
        return self.suspend { f().fold({ e in self.raiseError(e as! E) },
                                     { a in self.pure(a) }) }
    }
}
