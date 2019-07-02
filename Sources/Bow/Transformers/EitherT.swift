import Foundation

/// Witness for the `EitherT<F, A, B>` data type. To be used in simulated Higher Kinded Types.
public final class ForEitherT {}

/// Partial application of the EitherT type constructor, omitting the last parameter.
public final class EitherTPartial<F, L>: Kind2<ForEitherT, F, L> {}

/// Higher Kinded Type alias to improve readability over `Kind<EitherTPartial<F, A>, B>`.
public typealias EitherTOf<F, A, B> = Kind<EitherTPartial<F, A>, B>

/// The EitherT transformer represents the nesting of an `Either` value inside any other effect. It is equivalent to `Kind<F, Either<A, B>>`.
public final class EitherT<F, A, B>: EitherTOf<F, A, B> {
    fileprivate let value: Kind<F, Either<A, B>>

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to EitherT.
    public static func fix(_ fa: EitherTOf<F, A, B>) -> EitherT<F, A, B> {
        return fa as! EitherT<F, A, B>
    }
    
    /// Initializes an `EitherT` value.
    ///
    /// - Parameter value: An `Either` value wrapped in an effect.
    public init(_ value: Kind<F, Either<A, B>>) {
        self.value = value
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to EitherT.
public postfix func ^<F, A, B>(_ fa: EitherTOf<F, A, B>) -> EitherT<F, A, B> {
    return EitherT.fix(fa)
}

// MARK: Functions for `EitherT` when the effect has an instance of `Functor`.
extension EitherT where F: Functor {
    /// Applies the provided closures based on the content of the nested `Either` value.
    ///
    /// - Parameters:
    ///   - fa: Closure to apply if the contained value in the nested `Either` is a member of the left type.
    ///   - fb: Closure to apply if the contained value in the nested `Either` is a member of the right type.
    /// - Returns: Result of applying the corresponding closure to the nested `Either`, wrapped in the effect.
    public func fold<C>(_ fa: @escaping (A) -> C, _ fb: @escaping (B) -> C) -> Kind<F, C> {
        return value.map { either in either.fold(fa, fb) }
    }

    /// Lifts a value by nesting the contained value in the effect into an `Either.right` value.
    ///
    /// - Parameter fc: Value to be lifted.
    /// - Returns: A right `Either` wrapped in the effect.
    public static func liftF(_ fc: Kind<F, B>) -> EitherT<F, A, B> {
        return EitherT(fc.map(Either.right))
    }

    /// Applies the provided closures based on the content of the nested `Either` value.
    ///
    /// - Parameters:
    ///   - l: Closure to apply if the contained value in the nested `Either` is a member of the left type.
    ///   - r: Closure to apply if the contained value in the nested `Either` is a member of the right type.
    /// - Returns: Result of applying the corresponding closure to the nested `Either`, wrapped in the effect.
    public func cata<C>(_ l: @escaping (A) -> C, _ r: @escaping (B) -> C) -> Kind<F, C> {
        return fold(l, r)
    }

    /// Checks if the wrapped `Either` matches a predicate.
    ///
    /// - Parameter predicate: Predicate to test the nested `Either`.
    /// - Returns: A boolean value indicating if the `Either` matches the predicate, wrapped in the effect.
    public func exists(_ predicate: @escaping (B) -> Bool) -> Kind<F, Bool> {
        return value.map { either in either.exists(predicate) }
    }

    /// Transforms the nested `Either`.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: An `EitherT` where the nested `Either` has been transformed using the provided function.
    public func transform<C, D>(_ f: @escaping (Either<A, B>) -> Either<C, D>) -> EitherT<F, C, D> {
        return EitherT<F, C, D>(value.map(f))
    }

    /// Flatmaps the provided function to the nested `Either`.
    ///
    /// - Parameter f: Function for the flatmap operation.
    /// - Returns: Result of flatmapping the provided function to the nested `Either`, wrapped in the effect.
    public func subflatMap<C>(_ f: @escaping (B) -> Either<A, C>) -> EitherT<F, A, C> {
        return transform({ either in Either.fix(either.flatMap(f)) })
    }

    /// Converts this value to an `OptionT` by converting the nested `Either` to an `Option`.
    ///
    /// - Returns: An `OptionT` with the right value of the nested `Either`, or none if it contained a left value.
    public func toOptionT() -> OptionT<F, B> {
        return OptionT<F, B>(value.map { either in either.toOption() } )
    }
    
    /// Transforms the left type of the nested `Either`.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: An `EitherT` were the left type has been transformed.
    public func mapLeft<C>(_ f: @escaping (A) -> C) -> EitherT<F, C, B> {
        return EitherT<F, C, B>(self.value.map { either in either.bimap(f, id) })
    }
}

// MARK: Functions for `EitherT` when the effect has an instance of `Applicative`.
extension EitherT where F: Applicative {
    /// Creates an `EitherT` with a nested left value.
    ///
    /// - Parameter a: Value for the left case.
    /// - Returns: A left `Either` wrapped in the effect.
    public static func left(_ a: A) -> EitherT<F, A, B> {
        return EitherT(F.pure(.left(a)))
    }

    /// Creates an `EitherT` with a nested right value.
    ///
    /// - Parameter b: Value for the right case.
    /// - Returns: A right `Either` wrapped in the effect.
    public static func right(_ b: B) -> EitherT<F, A, B> {
        return EitherT(F.pure(.right(b)))
    }

    /// Creates an `EitherT` from an `Either` value.
    ///
    /// - Parameter either: `Either` value.
    /// - Returns: `Either` value wrapped in the effect.
    public static func fromEither(_ either: Either<A, B>) -> EitherT<F, A, B> {
        return EitherT(F.pure(either))
    }
}

// MARK: Functions for `EitherT` when the effect has an instance of `Monad`.
extension EitherT where F: Monad {
    /// Flatmaps a function that produces an effect and lifts it back to `EitherT`
    ///
    /// - Parameter f: A function producing an effect.
    /// - Returns: Result of flatmapping and lifting the function in this value.
    public func semiflatMap<C>(_ f: @escaping (B) -> Kind<F, C>) -> EitherT<F, A, C> {
        return EitherT<F, A, C>.fix(self.flatMap({ b in EitherT<F, A, C>.liftF(f(b)) }))
    }
}

// MARK: Instance of `EquatableK` for `EitherT`
extension EitherTPartial: EquatableK where F: EquatableK, L: Equatable {
    public static func eq<A>(_ lhs: Kind<EitherTPartial<F, L>, A>, _ rhs: Kind<EitherTPartial<F, L>, A>) -> Bool where A : Equatable {
        return EitherT.fix(lhs).value == EitherT.fix(rhs).value
    }
}

// MARK: Instance of `Invariant` for `EitherT`
extension EitherTPartial: Invariant where F: Functor {}

// MARK: Instance of `Functor` for `EitherT`
extension EitherTPartial: Functor where F: Functor {
    public static func map<A, B>(_ fa: Kind<EitherTPartial<F, L>, A>, _ f: @escaping (A) -> B) -> Kind<EitherTPartial<F, L>, B> {
        return EitherT(EitherT.fix(fa).value.map { either in Either.fix(either.map(f)) })
    }
}

// MARK: Instance of `Applicative` for `EitherT`
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

// MARK: Instance of `Selective` for `EitherT`
extension EitherTPartial: Selective where F: Monad {}

// MARK: Instance of `Monad` for `EitherT`
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

// MARK: Instance of `ApplicativeError` for `EitherT`
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

// MARK: Instance of `MonadError` for `EitherT`
extension EitherTPartial: MonadError where F: Monad {}

// MARK: Instance of `SemigroupK` for `EitherT`
extension EitherTPartial: SemigroupK where F: Monad {
    public static func combineK<A>(_ x: Kind<EitherTPartial<F, L>, A>, _ y: Kind<EitherTPartial<F, L>, A>) -> Kind<EitherTPartial<F, L>, A> {
        return EitherT(EitherT.fix(x).value.flatMap { either in
            either.fold(constant(EitherT.fix(y).value), { b in F.pure(Either.right(b)) })
        })
    }
}

// MARK: Instance of `Foldable` for `EitherT`
extension EitherTPartial: Foldable where F: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<EitherTPartial<F, L>, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa^.value.foldLeft(b, { bb, either in either.foldLeft(bb, f) })
    }
    
    public static func foldRight<A, B>(_ fa: Kind<EitherTPartial<F, L>, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa^.value.foldRight(b, { either, bb in either.foldRight(bb, f) })
    }
}

// MARK: Instance of `Traverse` for `EitherT`
extension EitherTPartial: Traverse where F: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<EitherTPartial<F, L>, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<EitherTPartial<F, L>, B>> {
        return fa^.value.traverse { either in either.traverse(f) }.map { x in EitherT(x.map{ b in b^ }) }
    }
}
