import Foundation

public final class ForMoore {}
public final class MoorePartial<E>: Kind<ForMoore, E> {}
public typealias MooreOf<E, V> = Kind<MoorePartial<E>, V>

public final class Moore<E, V>: MooreOf<E, V> {
    public let view: V
    public let handle: (E) -> Moore<E, V>
    
    public static func fix(_ value: MooreOf<E, V>) -> Moore<E, V> {
        return value as! Moore<E, V>
    }
    
    public init(view: V, handle: @escaping (E) -> Moore<E, V>) {
        self.view = view
        self.handle = handle
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Moore.
public postfix func ^<E, V>(_ value: MooreOf<E, V>) -> Moore<E, V> {
    return Moore.fix(value)
}

extension MoorePartial: Functor {
    public static func map<A, B>(_ fa: Kind<MoorePartial<E>, A>, _ f: @escaping (A) -> B) -> Kind<MoorePartial<E>, B> {
        let moore = Moore.fix(fa)
        return Moore<E, B>(view: f(moore.view),
                           handle: { update in Moore.fix(moore.handle(update).map(f)) })
    }
}

extension MoorePartial: Comonad {
    public static func coflatMap<A, B>(_ fa: Kind<MoorePartial<E>, A>, _ f: @escaping (Kind<MoorePartial<E>, A>) -> B) -> Kind<MoorePartial<E>, B> {
        let moore = Moore.fix(fa)
        return Moore<E, B>(view: f(moore),
                           handle: { update in Moore.fix(moore.handle(update).coflatMap(f)) })
    }

    public static func extract<A>(_ fa: Kind<MoorePartial<E>, A>) -> A {
        return Moore.fix(fa).view
    }
}
