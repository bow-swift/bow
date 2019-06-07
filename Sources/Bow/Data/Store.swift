import Foundation

public final class ForStore {}
public final class StorePartial<S>: Kind<ForStore, S> {}
public typealias StoreOf<S, V> = Kind<StorePartial<S>, V>

public final class Store<S, V> : StoreOf<S, V> {
    public let state: S
    public let render: (S) -> V
    
    public static func fix(_ value: StoreOf<S, V>) -> Store<S, V> {
        return value as! Store<S, V>
    }
    
    public init(state: S, render: @escaping (S) -> V) {
        self.state = state
        self.render = render
    }
    
    func move(_ newState: S) -> Store<S, V> {
        let dup = Store<S, StoreOf<S, V>>.fix(duplicate())
        return Store.fix(dup.render(newState))
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Store.
public postfix func ^<S, V>(_ value: StoreOf<S, V>) -> Store<S, V> {
    return Store.fix(value)
}

extension StorePartial: Functor {
    public static func map<A, B>(_ fa: Kind<StorePartial<S>, A>, _ f: @escaping (A) -> B) -> Kind<StorePartial<S>, B> {
        let store = Store.fix(fa)
        return Store(state: store.state,
                     render: { newState in f(store.render(newState)) })
    }
}

extension StorePartial: Comonad {
    public static func coflatMap<A, B>(_ fa: Kind<StorePartial<S>, A>, _ f: @escaping (Kind<StorePartial<S>, A>) -> B) -> Kind<StorePartial<S>, B> {
        let store = Store.fix(fa)
        return Store(state: store.state,
                     render: { next in f(Store(state: next, render: store.render)) })
    }

    public static func extract<A>(_ fa: Kind<StorePartial<S>, A>) -> A {
        let store = Store.fix(fa)
        return store.render(store.state)
    }
}
