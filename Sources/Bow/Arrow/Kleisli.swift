import Foundation

public final class ForKleisli {}
public final class KleisliPartial<F, D>: Kind2<ForKleisli, F, D> {}
public typealias KleisliOf<F, D, A> = Kind<KleisliPartial<F, D>, A>
public typealias ReaderT<F, D, A> = Kleisli<F, D, A>

public class Kleisli<F, D, A>: KleisliOf<F, D, A> {
    internal let run: (D) -> Kind<F, A>
    
    public static func fix(_ fa: KleisliOf<F, D, A>) -> Kleisli<F, D, A> {
        return fa as! Kleisli<F, D, A>
    }
    
    public init(_ run: @escaping (D) -> Kind<F, A>) {
        self.run = run
    }

    public func invoke(_ value: D) -> Kind<F, A> {
        return run(value)
    }
}

extension Kleisli where F: Monad {
    public func zip<B>(_ o: Kleisli<F, D, B>) -> Kleisli<F, D, (A, B)> {
        return Kleisli<F, D, (A, B)>.fix(self.flatMap({ a in
            Kleisli<F, D, (A, B)>.fix(o.map({ b in (a, b) }))
        }))
    }

    public func andThen<C>(_ f: Kleisli<F, A, C>) -> Kleisli<F, D, C> {
        return andThen(f.run)
    }

    public func andThen<B>(_ f: @escaping (A) -> Kind<F, B>) -> Kleisli<F, D, B> {
        return Kleisli<F, D, B>({ d in self.run(d).flatMap(f) })
    }

    public func andThen<B>(_ a: Kind<F, B>) -> Kleisli<F, D, B> {
        return andThen(constant(a))
    }
}

extension KleisliPartial: EquatableK where F: EquatableK, D == Int {
    public static func eq<A>(_ lhs: Kind<KleisliPartial<F, D>, A>, _ rhs: Kind<KleisliPartial<F, D>, A>) -> Bool where A : Equatable {
        return Kleisli.fix(lhs).invoke(1) == Kleisli.fix(rhs).invoke(1)
    }
}

extension KleisliPartial: Invariant where F: Functor {}

extension KleisliPartial: Functor where F: Functor {
    public static func map<A, B>(_ fa: Kind<KleisliPartial<F, D>, A>, _ f: @escaping (A) -> B) -> Kind<KleisliPartial<F, D>, B> {
        return Kleisli<F, D, B>({ d in Kleisli.fix(fa).run(d).map(f) })
    }
}

extension KleisliPartial: Applicative where F: Applicative {
    public static func pure<A>(_ a: A) -> Kind<KleisliPartial<F, D>, A> {
        return Kleisli(constant(F.pure(a)))
    }

    public static func ap<A, B>(_ ff: Kind<KleisliPartial<F, D>, (A) -> B>, _ fa: Kind<KleisliPartial<F, D>, A>) -> Kind<KleisliPartial<F, D>, B> {
        return Kleisli<F, D, B>({ d in Kleisli.fix(ff).run(d).ap(Kleisli.fix(fa).run(d)) })
    }
}

extension KleisliPartial: Monad where F: Monad {
    public static func flatMap<A, B>(_ fa: Kind<KleisliPartial<F, D>, A>, _ f: @escaping (A) -> Kind<KleisliPartial<F, D>, B>) -> Kind<KleisliPartial<F, D>, B> {
        return Kleisli<F, D, B>({ d in Kleisli.fix(fa).run(d).flatMap { a in Kleisli.fix(f(a)).run(d) } })
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<KleisliPartial<F, D>, Either<A, B>>) -> Kind<KleisliPartial<F, D>, B> {
        return Kleisli({ b in F.tailRecM(a, { a in Kleisli.fix(f(a)).run(b) })})
    }
}

extension KleisliPartial: MonadReader where F: Monad {
    public static func ask() -> Kind<KleisliPartial<F, D>, D> {
        return Kleisli<F, D, D>(F.pure)
    }

    public static func local<A>(_ fa: Kind<KleisliPartial<F, D>, A>, _ f: @escaping (D) -> D) -> Kind<KleisliPartial<F, D>, A> {
        return Kleisli({ dd in Kleisli.fix(fa).run(f(dd)) })
    }
}

extension KleisliPartial: ApplicativeError where F: ApplicativeError {
    public typealias E = F.E

    public static func raiseError<A>(_ e: F.E) -> Kind<KleisliPartial<F, D>, A> {
        return Kleisli(constant(F.raiseError(e)))
    }

    public static func handleErrorWith<A>(_ fa: Kind<KleisliPartial<F, D>, A>, _ f: @escaping (F.E) -> Kind<KleisliPartial<F, D>, A>) -> Kind<KleisliPartial<F, D>, A> {
        return Kleisli<F, D, A>({ d in Kleisli.fix(fa).run(d).handleErrorWith { e in Kleisli.fix(f(e)).run(d) } })
    }
}

extension KleisliPartial: MonadError where F: MonadError {}
