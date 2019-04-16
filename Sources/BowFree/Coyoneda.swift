import Foundation
import Bow

public final class ForCoyoneda {}
public typealias AnyFunc = (AnyObject) -> AnyObject
public final class CoyonedaPartial<F, P>: Kind2<ForCoyoneda, F, P> {}
public typealias CoyonedaOf<F, P, A> = Kind<CoyonedaPartial<F, P>, A>

public class Coyoneda<F, P, A>: CoyonedaOf<F, P, A> {
    fileprivate let pivot: Kind<F, P>
    fileprivate let ks: [AnyFunc]

    public static func apply(_ fp : Kind<F, P>, _ f : @escaping (P) -> A) -> Coyoneda<F, P, A> {
        return unsafeApply(fp, [f as! AnyFunc])
    }

    public static func unsafeApply(_ fp : Kind<F, P>, _ fs : [AnyFunc]) -> Coyoneda<F, P, A> {
        return Coyoneda<F, P, A>(fp, fs)
    }

    public static func fix(_ fa : CoyonedaOf<F, P, A>) -> Coyoneda<F, P, A> {
        return fa as! Coyoneda<F, P, A>
    }

    public init(_ pivot : Kind<F, P>, _ ks : [AnyFunc]) {
        self.pivot = pivot
        self.ks = ks
    }

    private func transform() -> (P) -> A {
        return { p in
            let result = self.ks.reduce(p as AnyObject, { current, f in f(current) })
            return result as! A
        }
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Coyoneda.
public postfix func ^<F, P, A>(_ fa: CoyonedaOf<F, P, A>) -> Coyoneda<F, P, A> {
    return Coyoneda.fix(fa)
}

public extension Coyoneda where F: Functor {
    func lower() -> Kind<F, A> {
        return F.map(pivot, transform())
    }

    func toYoneda() -> Yoneda<F, A> {
        return YonedaFromCoyoneda<F, A>()
    }
}

private class YonedaFromCoyoneda<F: Functor, A>: Yoneda<F, A> {
    override public func apply<B>(_ f: @escaping (A) -> B) -> Kind<F, B> {
        return Yoneda.fix(self.map(f)).lower()
    }
}

extension CoyonedaPartial: Functor {
    public static func map<A, B>(_ fa: Kind<CoyonedaPartial<F, P>, A>, _ f: @escaping (A) -> B) -> Kind<CoyonedaPartial<F, P>, B> {
        let coyoneda = Coyoneda.fix(fa)
        return Coyoneda(coyoneda.pivot, coyoneda.ks + [f as! AnyFunc])
    }
}
