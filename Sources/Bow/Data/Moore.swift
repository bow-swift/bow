import Foundation

public class ForMoore {}
public typealias MooreOf<E, V> = Kind2<ForMoore, E, V>

public class Moore<E, V> : MooreOf<E, V> {
    public let view : V
    public let handle : (E) -> Moore<E, V>
    
    public static func fix(_ value : MooreOf<E, V>) -> Moore<E, V> {
        return value as! Moore<E, V>
    }
    
    public init(view : V, handle : @escaping (E) -> Moore<E, V>) {
        self.view = view
        self.handle = handle
    }
    
    func coflatMap<A>(_ f : @escaping (Moore<E, V>) -> A) -> Moore<E, A> {
        return Moore<E, A>(view: f(self),
                           handle: { update in self.handle(update).coflatMap(f) })
    }
    
    func map<A>(_ f : @escaping (V) -> A) -> Moore<E, A> {
        return Moore<E, A>(view: f(self.view),
                           handle: { update in self.handle(update).map(f) })
    }
    
    func extract() -> V {
        return view
    }
}
