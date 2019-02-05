import Foundation

public final class ForMoore {}
public final class MoorePartial<E>: Kind<ForMoore, E> {}
public typealias MooreOf<E, V> = Kind<MoorePartial<E>, V>

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

public extension Moore {
    public static func functor() -> FunctorInstance<E> {
        return FunctorInstance<E>()
    }
    
    public static func comonad() -> ComonadInstance<E> {
        return ComonadInstance<E>()
    }

    public class FunctorInstance<E> : Functor {
        public typealias F = MoorePartial<E>
        
        public func map<A, B>(_ fa: MooreOf<E, A>, _ f: @escaping (A) -> B) -> MooreOf<E, B> {
            return Moore<E, A>.fix(fa).map(f)
        }
    }

    public class ComonadInstance<E> : FunctorInstance<E>, Comonad {
        public func coflatMap<A, B>(_ fa: Kind<MoorePartial<E>, A>, _ f: @escaping (Kind<MoorePartial<E>, A>) -> B) -> Kind<MoorePartial<E>, B> {
            return Moore<E, A>.fix(fa).coflatMap(f)
        }
        
        public func extract<A>(_ fa: MooreOf<E, A>) -> A {
            return Moore<E, A>.fix(fa).extract()
        }
    }
}
