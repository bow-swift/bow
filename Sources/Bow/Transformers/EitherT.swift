import Foundation

public final class ForEitherT {}
public final class EitherTPartial<F, L>: Kind2<ForEitherT, F, L> {}
public typealias EitherTOf<F, A, B> = Kind<EitherTPartial<F, A>, B>

public class EitherT<F, A, B> : EitherTOf<F, A, B> {
    fileprivate let value : Kind<F, Either<A, B>>

    public static func fix(_ fa: EitherTOf<F, A, B>) -> EitherT<F, A, B> {
        return fa as! EitherT<F, A, B>
    }
    
    public init(_ value: Kind<F, Either<A, B>>) {
        self.value = value
    }
}

extension EitherT where F: Functor {
    public func fold<C>(_ fa: @escaping (A) -> C, _ fb: @escaping (B) -> C) -> Kind<F, C> {
        return value.map { either in either.fold(fa, fb) }
    }

    public func liftF<C>(_ fc: Kind<F, C>) -> EitherT<F, A, C> {
        return EitherT<F, A, C>(fc.map(Either<A, C>.right))
    }

    public func cata<C>(_ l : @escaping (A) -> C, _ r : @escaping (B) -> C) -> Kind<F, C> {
        return fold(l, r)
    }

    public func exists(_ predicate : @escaping (B) -> Bool) -> Kind<F, Bool> {
        return value.map { either in either.exists(predicate) }
    }

    public func transform<C, D>(_ f : @escaping (Either<A, B>) -> Either<C, D>) -> EitherT<F, C, D> {
        return EitherT<F, C, D>(value.map(f))
    }

    public func subflatpMap<C>(_ f: @escaping (B) -> Either<A, C>) -> EitherT<F, A, C> {
        return transform({ either in Either.fix(either.flatMap(f)) })
    }

    public func toOptionT() -> OptionT<F, B> {
        return OptionT<F, B>(value.map { either in either.toOption() } )
    }
}

extension EitherT where F: Applicative {
    public static func left(_ a: A) -> EitherT<F, A, B> {
        return EitherT(F.pure(.left(a)))
    }

    public static func right(_ b: B) -> EitherT<F, A, B> {
        return EitherT(F.pure(.right(b)))
    }

    public static func fromEither(_ either: Either<A, B>) -> EitherT<F, A, B> {
        return EitherT(F.pure(either))
    }
}

extension EitherT where F: Monad {
    public func semiflatMap<C>(_ f : @escaping (B) -> Kind<F, C>) -> EitherT<F, A, C> {
        return EitherT<F, A, C>.fix(self.flatMap({ b in self.liftF(f(b)) }))
    }
}

extension EitherTPartial: EquatableK where F: EquatableK, L: Equatable {
    public static func eq<A>(_ lhs: Kind<EitherTPartial<F, L>, A>, _ rhs: Kind<EitherTPartial<F, L>, A>) -> Bool where A : Equatable {
        return EitherT.fix(lhs).value == EitherT.fix(rhs).value
    }
}

extension EitherTPartial: Invariant where F: Functor {}

extension EitherTPartial: Functor where F: Functor {
    public static func map<A, B>(_ fa: Kind<EitherTPartial<F, L>, A>, _ f: @escaping (A) -> B) -> Kind<EitherTPartial<F, L>, B> {
        return EitherT(EitherT.fix(fa).value.map { either in Either.fix(either.map(f)) })
    }
}

extension EitherTPartial: Applicative where F: Applicative {
    public static func pure<A>(_ a: A) -> Kind<EitherTPartial<F, L>, A> {
        return EitherT(F.pure(.right(a)))
    }

    public static func ap<A, B>(_ ff: Kind<EitherTPartial<F, L>, (A) -> B>, _ fa: Kind<EitherTPartial<F, L>, A>) -> Kind<EitherTPartial<F, L>, B> {
        let etf = EitherT.fix(ff)
        let eta = EitherT.fix(fa)
        return EitherT(F.map(etf.value, eta.value) { ef, ea in
            Either.fix(ef.ap(ea))
        })
    }
}

extension EitherTPartial: Monad where F: Monad {
    public static func flatMap<A, B>(_ fa: Kind<EitherTPartial<F, L>, A>, _ f: @escaping (A) -> Kind<EitherTPartial<F, L>, B>) -> Kind<EitherTPartial<F, L>, B> {
        let eta = EitherT.fix(fa)
        return flatMapF(eta.value, { b in EitherT.fix(f(b)).value })
    }

    private static func flatMapF<A, B>(_ fa: Kind<F, Either<L, A>>, _ f: @escaping (A) -> Kind<F, Either<L, B>>) -> EitherT<F, L, B> {
        return EitherT(fa.flatMap { either in
            either.fold({ a in F.pure(Either<L, B>.left(a)) }, f)
        })
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<EitherTPartial<F, L>, Either<A, B>>) -> Kind<EitherTPartial<F, L>, B> {
        return EitherT(F.tailRecM(a, { a in
            F.map(EitherT.fix(f(a)).value, { recursionControl in
                recursionControl.fold({ left in Either.right(Either.left(left)) },
                                      { right in
                                        right.fold({ a in Either.left(a) },
                                                   { b in Either.right(Either.right(b)) })
                })
            })
        }))
    }
}

extension EitherTPartial: ApplicativeError where F: Monad {
    public typealias E = L

    public static func raiseError<A>(_ e: L) -> Kind<EitherTPartial<F, L>, A> {
        return EitherT(F.pure(Either.left(e)))
    }

    public static func handleErrorWith<A>(_ fa: Kind<EitherTPartial<F, L>, A>, _ f: @escaping (L) -> Kind<EitherTPartial<F, L>, A>) -> Kind<EitherTPartial<F, L>, A> {
        return EitherT(EitherT.fix(fa).value.flatMap { either in
            either.fold({ left in EitherT.fix(f(left)).value },
                        { right in F.pure(Either.right(right)) })
        })
    }
}

extension EitherTPartial: MonadError where F: Monad {}

extension EitherTPartial: SemigroupK where F: Monad {
    public static func combineK<A>(_ x: Kind<EitherTPartial<F, L>, A>, _ y: Kind<EitherTPartial<F, L>, A>) -> Kind<EitherTPartial<F, L>, A> {
        return EitherT(EitherT.fix(x).value.flatMap { either in
            either.fold(constant(EitherT.fix(y).value), { b in F.pure(Either.right(b)) })
        })
    }
}
