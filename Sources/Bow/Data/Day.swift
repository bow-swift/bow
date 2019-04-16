import Foundation

public final class ForDay {}
public final class DayPartial<F: Comonad, G: Comonad>: Kind2<ForDay, F, G> {}
public typealias DayOf<F: Comonad, G: Comonad, A> = Kind<DayPartial<F, G>, A>

public class Day<F: Comonad, G: Comonad, A> : DayOf<F, G, A> {
    public static func fix(_ value : DayOf<F, G, A>) -> Day<F, G, A> {
        return value as! Day<F, G, A>
    }

    public static func from<X, Y>(left : Kind<F, X>, right : Kind<G, Y>, f : @escaping (X, Y) -> A) -> Day<F, G, A> {
        return DefaultDay(left: left, right: right, f: f)
    }

    internal func _map<B>(_ f : @escaping (A) -> B) -> Day<F, G, B> {
        fatalError("_map must be implemented in subclasses")
    }

    public func runDay() -> A {
        return extract()
    }

    internal func _extract() -> A {
        fatalError("extract must be implemented in subclasses")
    }

    internal func _coflatMap<B>(_ f : @escaping (DayOf<F, G, A>) -> B) -> Day<F, G, B> {
        fatalError("coflatMap must be implemented in subclasses")
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Day.
public postfix func ^<F, G, A>(_ value: DayOf<F, G, A>) -> Day<F, G, A> {
    return Day.fix(value)
}

public extension Day where F: Applicative, G: Applicative {
    static func from(_ a: A) -> Day<F, G, A> {
        return DefaultDay(left: F.pure(unit),
                          right: G.pure(unit),
                          f: constant(a))
    }
}

private class DefaultDay<F: Comonad, G: Comonad, X, Y, A> : Day<F, G, A> {
    private let left : Kind<F, X>
    private let right : Kind<G, Y>
    private let f : (X, Y) -> A

    init(left : Kind<F, X>, right : Kind<G, Y>, f : @escaping (X, Y) -> A) {
        self.left = left
        self.right = right
        self.f = f
    }

    func stepDay<R>(_ ff: @escaping (Kind<F, X>, Kind<G, Y>, @escaping (X, Y) -> A) -> R) -> R {
        return ff(left, right, { a, b in self.f(a, b) })
    }

    override internal func _map<B>(_ f : @escaping (A) -> B) -> Day<F, G, B> {
        return self.stepDay { left, right, get in
            DefaultDay<F, G, X, Y, B>(left: left, right: right) { x, y in
                f(get(x, y))
            }
        }
    }

    override func _extract() -> A {
        return self.stepDay { left, right, get in
            get(F.extract(left), G.extract(right))
        }
    }

    override public func _coflatMap<B>(_ f : @escaping (DayOf<F, G, A>) -> B) -> Day<F, G, B>  {
        return self.stepDay { left, right, get in
            let l = F.duplicate(left)
            let r = G.duplicate(right)
            return DefaultDay<F, G, Kind<F, X>, Kind<G, Y>, B>(left: l, right: r) { x, y in
                f(DefaultDay(left: x, right: y, f: get))
            }
        }
    }
}

extension DayPartial: Functor {
    public static func map<A, B>(_ fa: Kind<DayPartial<F, G>, A>, _ f: @escaping (A) -> B) -> Kind<DayPartial<F, G>, B> {
        return Day.fix(fa)._map(f)
    }
}

extension DayPartial: Comonad {
    public static func coflatMap<A, B>(_ fa: Kind<DayPartial<F, G>, A>, _ f: @escaping (Kind<DayPartial<F, G>, A>) -> B) -> Kind<DayPartial<F, G>, B> {
        return Day.fix(fa)._coflatMap(f)
    }

    public static func extract<A>(_ fa: Kind<DayPartial<F, G>, A>) -> A {
        return Day.fix(fa)._extract()
    }
}
