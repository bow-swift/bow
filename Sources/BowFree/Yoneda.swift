import Foundation
import Bow

public final class ForYoneda {}
public final class YonedaPartial<F>: Kind<ForYoneda, F> {}
public typealias YonedaOf<F, A> = Kind<YonedaPartial<F>, A>

open class Yoneda<F, A>: YonedaOf<F, A> {
    public static func fix(_ fa : YonedaOf<F, A>) -> Yoneda<F, A> {
        return fa as! Yoneda<F, A>
    }

    public func apply<B>(_ f : @escaping (A) -> B) -> Kind<F, B> {
        fatalError("Apply must be implemented in subclass")
    }

    public func lower() -> Kind<F, A> {
        return apply(id)
    }

    public func toCoyoneda() -> Coyoneda<F, A, A> {
        return Coyoneda<F, A, A>.apply(lower(), id)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Yoneda.
public postfix func ^<F, A>(_ fa: YonedaOf<F, A>) -> Yoneda<F, A> {
    return Yoneda.fix(fa)
}

public extension Yoneda where F: Functor {
    static func apply(_ fa : Kind<F, A>) -> Yoneda<F, A> {
        return YonedaFunctor<F, A>(fa)
    }
}

private class YonedaDefault<F, A, B>: Yoneda<F, B> {
    private let ff: (A) -> B
    private let yoneda: Yoneda<F, A>

    init(_ yoneda: Yoneda<F, A>, _ ff: @escaping (A) -> B) {
        self.yoneda = yoneda
        self.ff = ff
    }

    override public func apply<C>(_ f: @escaping (B) -> C) -> Kind<F, C> {
        return yoneda.apply({ a in f(self.ff(a)) })
    }
}

private class YonedaFunctor<F: Functor, A>: Yoneda<F, A> {
    private let fa : Kind<F, A>

    init(_ fa : Kind<F, A>) {
        self.fa = fa
    }

    override public func apply<B>(_ f: @escaping (A) -> B) -> Kind<F, B> {
        return F.map(fa, f)
    }
}

extension YonedaPartial: Functor {
    public static func map<A, B>(_ fa: Kind<YonedaPartial<F>, A>, _ f: @escaping (A) -> B) -> Kind<YonedaPartial<F>, B> {
        return YonedaDefault(Yoneda.fix(fa), f)
    }
}

