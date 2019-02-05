import Foundation

public final class ForStore {}
public final class StorePartial<S>: Kind<ForStore, S> {}
public typealias StoreOf<S, V> = Kind<StorePartial<S>, V>

public class Store<S, V> : StoreOf<S, V> {
    public let state : S
    public let render : (S) -> V
    
    public static func fix(_ value : StoreOf<S, V>) -> Store<S, V> {
        return value as! Store<S, V>
    }
    
    public init(state : S, render : @escaping (S) -> V) {
        self.state = state
        self.render = render
    }
    
    func map<A>(_ f : @escaping (V) -> A) -> Store<S, A> {
        return Store<S, A>(state: self.state,
                           render: { newState in f(self.render(newState)) })
    }
    
    func coflatMap<A>(_ f : @escaping (Store<S, V>) -> A) -> Store<S, A> {
        return Store<S, A>(state: self.state,
                           render: { next in f(Store(state: next, render: self.render)) })
    }
    
    func extract() -> V {
        return render(state)
    }
    
    func duplicate() -> Store<S, Store<S, V>> {
        return coflatMap(id)
    }
    
    func move(_ newState : S) -> Store<S, V> {
        return duplicate().render(newState)
    }
}

extension Store: Fixed {}

public extension Store {
    public static func functor() -> FunctorInstance<S> {
        return FunctorInstance<S>()
    }
    
    public static func comonad() -> ComonadInstance<S> {
        return ComonadInstance<S>()
    }

    public class FunctorInstance<S> : Functor {
        public typealias F = StorePartial<S>
        
        public func map<A, B>(_ fa: StoreOf<S, A>, _ f: @escaping (A) -> B) -> StoreOf<S, B> {
            return Store<S, A>.fix(fa).map(f)
        }
    }

    public class ComonadInstance<S> : FunctorInstance<S>, Comonad {
        public func coflatMap<A, B>(_ fa: StoreOf<S, A>, _ f: @escaping (StoreOf<S, A>) -> B) -> StoreOf<S, B> {
            return Store<S, A>.fix(fa).coflatMap(f)
        }
        
        public func extract<A>(_ fa: StoreOf<S, A>) -> A {
            return Store<S, A>.fix(fa).extract()
        }
    }
}
