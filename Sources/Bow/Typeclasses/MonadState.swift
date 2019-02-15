import Foundation

public protocol MonadState: Monad {
    associatedtype S
    
    static func get() -> Kind<Self, S>
    static func set(_ s: S) -> Kind<Self, ()>
}

public extension MonadState {
    public static func state<A>(_ f: @escaping (S) -> (S, A)) -> Kind<Self, A> {
        return flatMap(get(), { s in
            let result = f(s)
            return map(set(result.0), { _ in result.1 })
        })
    }
    
    public static func modify(_ f: @escaping (S) -> S) -> Kind<Self, ()> {
        return flatMap(get(), { s in set(f(s))})
    }
    
    public static func inspect<A>(_ f: @escaping (S) -> A) -> Kind<Self, A> {
        return map(get(), f)
    }
}

// MARK: Syntax for MonadState

public extension Kind where F: MonadState {
    public static func get() -> Kind<F, F.S> {
        return F.get()
    }

    public static func set(_ s: F.S) -> Kind<F, ()> {
        return F.set(s)
    }

    public static func state(_ f: @escaping (F.S) -> (F.S, A)) -> Kind<F, A> {
        return F.state(f)
    }

    public static func modify(_ f: @escaping (F.S) -> F.S) -> Kind<F, ()> {
        return F.modify(f)
    }

    public static func inspect(_ f: @escaping (F.S) -> A) -> Kind<F, A> {
        return F.inspect(f)
    }
}
