import Foundation

public class ForMoore {}
public typealias MooreOf<E, V> = Kind2<ForMoore, E, V>
public typealias MoorePartial<E> = Kind<ForMoore, E>

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
    public static func functor() -> MooreFunctor<E> {
        return MooreFunctor<E>()
    }
    
    public static func comonad() -> MooreComonad<E> {
        return MooreComonad<E>()
    }
}

public class MooreFunctor<E> : Functor {
    public typealias F = MoorePartial<E>
    
    public func map<A, B>(_ fa: MooreOf<E, A>, _ f: @escaping (A) -> B) -> MooreOf<E, B> {
        return Moore<E, A>.fix(fa).map(f)
    }
}

public class MooreComonad<E> : MooreFunctor<E>, Comonad {
    public func coflatMap<A, B>(_ fa: Kind<Kind<ForMoore, E>, A>, _ f: @escaping (Kind<Kind<ForMoore, E>, A>) -> B) -> Kind<Kind<ForMoore, E>, B> {
        return Moore<E, A>.fix(fa).coflatMap(f)
    }
    
    public func extract<A>(_ fa: Kind<Kind<ForMoore, E>, A>) -> A {
        return Moore<E, A>.fix(fa).extract()
    }
}
