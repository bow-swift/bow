import Foundation
import Bow

public typealias Callback<E, A> = (Either<E, A>) -> ()
public typealias Proc<E, A> = (@escaping Callback<E, A>) throws -> ()
public typealias ProcF<F, E, A> = (@escaping Callback<E, A>) throws -> Kind<F, ()>

public protocol Async: MonadDefer {
    static func asyncF<A>(_ procf: @escaping ProcF<Self, E, A>) -> Kind<Self, A>
    static func continueOn<A>(_ fa: Kind<Self, A>, _ queue: DispatchQueue) -> Kind<Self, A>
}

public extension Async {
    public static func async<A>(_ proc: @escaping Proc<E, A>) -> Kind<Self, A> {
        return asyncF { cb in
            delay {
                try proc(cb)
            }
        }
    }

    public static func `defer`<A>(_ queue: DispatchQueue, _ f: @escaping () -> Kind<Self, A>) -> Kind<Self, A> {
        return pure(()).continueOn(queue).flatMap { Self.defer(f) }
    }

    public static func delay<A>(_ queue: DispatchQueue, _ f: @escaping () throws -> A) -> Kind<Self, A> {
        return Self.defer(queue) {
            do {
                return pure(try f())
            } catch let e as Self.E {
                return raiseError(e)
            } catch {
                fatalError("Unexpected error happened: \(error)")
            }
        }
    }

    public static func delayOrRaise<A>(_ queue: DispatchQueue, _ f: @escaping () -> Either<E, A>) -> Kind<Self, A> {
        return Self.defer(queue) { f().fold(raiseError, pure) }
    }

    public static func never<A>() -> Kind<Self, A> {
        return async { _ in }
    }
}

// MARK: Syntax for Async

public extension Kind where F: Async {
    public static func asyncF(_ procf: @escaping ProcF<F, F.E, A>) -> Kind<F, A> {
        return F.asyncF(procf)
    }

    public func continueOn(_ queue: DispatchQueue) -> Kind<F, A> {
        return F.continueOn(self, queue)
    }

    public static func async(_ fa: @escaping Proc<F.E, A>) -> Kind<F, A> {
        return F.async(fa)
    }

    public static func `defer`(_ queue: DispatchQueue, _ f: @escaping () -> Kind<F, A>) -> Kind<F, A> {
        return F.defer(queue, f)
    }

    public static func delay(_ queue: DispatchQueue, _ f: @escaping () throws -> A) -> Kind<F, A> {
        return F.delay(queue, f)
    }

    public static func delayOrRaise<A>(_ queue: DispatchQueue, _ f: @escaping () -> Either<F.E, A>) -> Kind<F, A> {
        return F.delayOrRaise(queue, f)
    }

    public static func never() -> Kind<F, A> {
        return F.never()
    }
}

// MARK: Async syntax

public extension DispatchQueue {
    public func shift<F: Async>() -> Kind<F, ()> {
        return F.delay(self, constant(()))
    }
}

public func runAsyncUnsafe<F: Async, A>(_ f: @escaping () -> Either<F.E, A>) -> Kind<F, A> {
    return F.async { callback in callback(f()) }
}
