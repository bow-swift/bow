import Foundation

public final class ForCokleisli {}
public final class CokleisliPartial<F, I>: Kind2<ForCokleisli, F, I> {}
public typealias CokleisliOf<F, A, B> = Kind<CokleisliPartial<F, A>, B>
public typealias CoreaderT<F, A, B> = Cokleisli<F, A, B>

public class Cokleisli<F, A, B>: CokleisliOf<F, A, B> {
    internal let run: (Kind<F, A>) -> B

    public static func fix(_ fa: Kind<CokleisliPartial<F, A>, B>) -> Cokleisli<F, A, B> {
        return fa as! Cokleisli<F, A, B>
    }
    
    public init(_ run: @escaping (Kind<F, A>) -> B) {
        self.run = run
    }
    
    public func contramapValue<C>(_ f: @escaping (Kind<F, C>) -> Kind<F, A>) -> Cokleisli<F, C, B> {
        return Cokleisli<F, C, B>({ fc in self.run(f(fc)) })
    }
}

extension Cokleisli where F: Comonad {
    public static func ask() -> Cokleisli<F, B, B> {
        return Cokleisli<F, B, B>({ fb in fb.extract() })
    }

    public func bimap<C, D>(_ g: @escaping (D) -> A, _ f : @escaping (B) -> C) -> Cokleisli<F, D, C> {
        return Cokleisli<F, D, C>({ fa in f(self.run(fa.map(g))) })
    }

    public func lmap<D>(_ g: @escaping (D) -> A) -> Cokleisli<F, D, B> {
        return Cokleisli<F, D, B>({ fa in self.run(fa.map(g)) })
    }

    public func compose<D>(_ a : Cokleisli<F, D, A>) -> Cokleisli<F, D, B> {
        return Cokleisli<F, D, B>({ fa in self.run(fa.coflatMap(a.run)) })
    }

    public func andThen<C>(_ a : Kind<F, C>) -> Cokleisli<F, A, C> {
        return Cokleisli<F, A, C>({ _ in a.extract() })
    }

    public func andThen<C>(_ a : Cokleisli<F, B, C>) -> Cokleisli<F, A, C>  {
        return a.compose(self)
    }
}

extension CokleisliPartial: Functor {
    public static func map<A, B>(_ fa: Kind<CokleisliPartial<F, I>, A>, _ f: @escaping (A) -> B) -> Kind<CokleisliPartial<F, I>, B> {
        return Cokleisli(Cokleisli.fix(fa).run >>> f)
    }
}

extension CokleisliPartial: Applicative {
    public static func pure<A>(_ a: A) -> Kind<CokleisliPartial<F, I>, A> {
        return Cokleisli({ _ in a })
    }
}

extension CokleisliPartial: Monad {
    public static func flatMap<A, B>(_ fa: Kind<CokleisliPartial<F, I>, A>, _ f: @escaping (A) -> Kind<CokleisliPartial<F, I>, B>) -> Kind<CokleisliPartial<F, I>, B> {
        let cok = Cokleisli.fix(fa)
        return Cokleisli({ x in Cokleisli.fix(f(cok.run(x))).run(x) })
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<CokleisliPartial<F, I>, Either<A, B>>) -> Kind<CokleisliPartial<F, I>, B> {
        fatalError("Not implemented yet")
    }
}

