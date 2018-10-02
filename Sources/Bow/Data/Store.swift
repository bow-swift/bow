import Foundation

public class ForStore {}
public typealias StoreOf<S, V> = Kind2<ForStore, S, V>

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
