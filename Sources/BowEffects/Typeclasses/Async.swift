import Foundation
import Bow

public typealias Proc<E, A> = (Callback<E, A>) throws -> ()
public typealias Callback<E, A> = (Either<E, A>) -> ()

public protocol Async: MonadDefer {
    static func runAsync<A>(_ fa: @escaping Proc<E, A>) -> Kind<Self, A>
}

public func runAsync<F: Async, A>(_ f : @escaping () throws -> A) -> Kind<F, A> {
    return F.runAsync { callback in
        do {
            callback(Either<F.E, A>.right(try f()))
        } catch let error as F.E {
            callback(Either<F.E, A>.left(error))
        }
    }
}

public func runAsyncUnsafe<F: Async, A>(_ f: @escaping () -> Either<F.E, A>) -> Kind<F, A> {
    return F.runAsync { callback in callback(f()) }
}

// MARK: Syntax for Async
public extension Kind where F: Async {
    static func runAsync(_ fa: @escaping Proc<F.E, A>) -> Kind<F, A> {
        return F.runAsync(fa)
    }
}
