import Foundation

/// Witness for the `OptionT<F, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForOptionT {}

/// Partial application of the OptionT type constructor, omitting the last parameter.
public final class OptionTPartial<F>: Kind<ForOptionT, F> {}

/// Higher Kinded Type alias to improve readability over `Kind<OptionTPartial<F>, A>`
public typealias OptionTOf<F, A> = Kind<OptionTPartial<F>, A>

/// The OptionT transformer represents the nesting of an `Option` value inside any other effect. It is equivalent to `Kind<F, Option<A>>`.
public final class OptionT<F, A>: OptionTOf<F, A> {
    fileprivate let value : Kind<F, Option<A>>

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to OptionT.
    public static func fix(_ fa: OptionTOf<F, A>) -> OptionT<F, A> {
        return fa as! OptionT<F, A>
    }
    
    /// Initializes an `OptionT` value.
    ///
    /// - Parameter value: An `Option` value wrapped in an effect.
    public init(_ value: Kind<F, Option<A>>) {
        self.value = value
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to OptionT.
public postfix func ^<F, A>(_ fa : OptionTOf<F, A>) -> OptionT<F, A> {
    return OptionT.fix(fa)
}

// MARK: Functions for `OptionT` when the effect has an instance of `Functor`
extension OptionT where F: Functor {
    /// Applies the provided closures based on the content of the nested `Option` value.
    ///
    /// - Parameters:
    ///   - ifEmpty: Closure to apply if the contained value in the nested `Option` is absent.
    ///   - f: Closure to apply if the contained value in the nested `Option` is present.
    /// - Returns: Result of applying the corresponding closure to the nested `Option`, wrapped in the effect.
    public func fold<B>(_ ifEmpty: @escaping () -> B, _ f: @escaping (A) -> B) -> Kind<F, B> {
        return value.map { option in option.fold(ifEmpty, f) }
    }

    /// Applies the provided closures based on the content of the nested `Option` value.
    ///
    /// - Parameters:
    ///   - ifEmpty: Closure to apply if the contained value in the nested `Option` is absent.
    ///   - f: Closure to apply if the contained value in the nested `Option` is present.
    /// - Returns: Result of applying the corresponding closure to the nested `Option`, wrapped in the effect.
    public func cata<B>(_ ifEmpty: @autoclosure @escaping () -> B, _ f: @escaping (A) -> B) -> Kind<F, B> {
        return fold(ifEmpty, f)
    }

    /// Lifts a value by wrapping the contained value in the effect into an `Option.some` value.
    ///
    /// - Parameter fb: Value to be lifted.
    /// - Returns: A present `Option` wrapped in the effect.
    public static func liftF(_ fb: Kind<F, A>) -> OptionT<F, A> {
        return OptionT(fb.map(Option.some))
    }

    /// Obtains the value of the nested `Option` or a default value, wrapped in the effect.
    ///
    /// - Parameter defaultValue: Value for the absent case in the nested `Option`.
    /// - Returns: Value contained in the nested `Option` if present, or the default value otherwise, wrapped in the effect.
    public func getOrElse(_ defaultValue: A) -> Kind<F, A> {
        return value.map { option in option.getOrElse(defaultValue) }
    }

    /// Checks if the nested `Option` is present.
    public var isDefined: Kind<F, Bool> {
        return value.map { option in option.isDefined }
    }

    /// Transforms the nested `Option`.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: An `OptionT` where the nested `Option` has been transformed using the provided function.
    public func transform<B>(_ f: @escaping (Option<A>) -> Option<B>) -> OptionT<F, B> {
        return OptionT<F, B>(value.map(f))
    }

    /// Flatmaps the provided function to the nested `Option`.
    ///
    /// - Parameter f: Function for the flatmap operation.
    /// - Returns: Result of flatmapping the provided function to the nested `Option`, wrapped in the effect.
    public func subflatMap<B>(_ f: @escaping (A) -> Option<B>) -> OptionT<F, B> {
        return transform { option in Option.fix(option.flatMap(f)) }
    }

    /// Convert this `OptionT` to an `EitherT`.
    ///
    /// - Parameter defaultRigth: Function returning a default value to use as right if the `OptionT` is none.
    /// - Returns: Returns: An `EitherT` containing the value as left or as right with the default value if the `OptionT` contains a none.
    public func toLeft<R>(_ defaultRight: @escaping () -> R) -> EitherT<F, A, R> {
        return EitherT(cata(.right(defaultRight()), Either.left))
    }

    /// Convenience `toLeft` allowing a constant as the parameter.
    public func toLeft<R>(_ defaultRight: @autoclosure @escaping () -> R) -> EitherT<F, A, R> {
        return toLeft(defaultRight)
    }

    /// Convert this `OptionT` to an `EitherT`.
    ///
    /// - Parameter defaultLeft: Function returning a default value to use as left if the `OptionT` is none.
    /// - Returns: Returns: An `EitherT` containing the value as right or as left with the default value if the `OptionT` contains a none.
    public func toRight<L>(_ defaultLeft: @escaping () -> L) -> EitherT<F, L, A> {
        return EitherT(cata(.left(defaultLeft()), Either.right))
    }

    /// Convenience `toRight` allowing a constant as the parameter.
    public func toRight<L>(_ defaultLeft: @autoclosure @escaping () -> L) -> EitherT<F, L, A> {
        return EitherT(cata(.left(defaultLeft()), Either.right))
    }
}

// MARK: Functions for `OptionT` when the effect has an instance of `Applicative`
extension OptionT where F: Applicative {
    /// Constructs an `OptionT` with a nested empty `Option`.
    ///
    /// - Returns: An `OptionT` with a nested empty `Option`.
    public static func none() -> OptionT<F, A> {
        return OptionT(F.pure(.none()))
    }

    /// Constructs an `OptionT` with a nested present `Option`.
    ///
    /// - Parameter a: Value to be wrapped in the nested `Option`.
    /// - Returns: An `OptionT` with a nested present `Option`.
    public static func some(_ a: A) -> OptionT<F, A> {
        return OptionT(F.pure(.some(a)))
    }

    /// Constructs an `OptionT` from an `Option`.
    ///
    /// - Parameter option: An `Option` value.
    /// - Returns: An `OptionT` wrapping the passed argument.
    public static func fromOption(_ option: Option<A>) -> OptionT<F, A> {
        return OptionT(F.pure(option))
    }
}

// MARK: Functions for `OptionT` when the effect has an instance of `Monad`
extension OptionT where F: Monad {
    /// Obtains this value if the value contained in the nested option is present, or a default value if it is absent.
    ///
    /// - Parameter defaultValue: Default value to return when the nested option is empty.
    /// - Returns: This `OptionT` if the nested option is present, or the default value otherwise.
    public func orElse(_ defaultValue: OptionT<F, A>) -> OptionT<F, A> {
        return orElseF(defaultValue.value)
    }

    /// Obtains this value if the value contained in the nested option is present, or a default value if it is absent.
    ///
    /// - Parameter defaultValue: Default value to return when the nested option is empty.
    /// - Returns: This `OptionT` if the nested option is present, or the default value otherwise.
    public func orElseF(_ defaultValue: Kind<F, Option<A>>) -> OptionT<F, A> {
        return OptionT<F, A>(value.flatMap { option in
            option.fold(constant(defaultValue),
                        constant(F.pure(option))) })
    }

    /// Flatmaps a function that produces an effect and lifts if back to `OptionT`.
    ///
    /// - Parameter f: A function producing an effect.
    /// - Returns: Result of flatmapping and lifting the function to this value.
    public func semiflatMap<B>(_ f: @escaping (A) -> Kind<F, B>) -> OptionT<F, B> {
        return OptionT<F, B>.fix(self.flatMap({ option in OptionT<F, B>.liftF(f(option)) }))
    }

    /// Obtains the value contained in the nested `Option` if present, or a default value otherwise.
    ///
    /// - Parameter defaultValue: Default value to return when the nested option is empty.
    /// - Returns: The value in the nested option wrapped in the effect if it is present, or the default value otherwise.
    public func getOrElseF(_ defaultValue: Kind<F, A>) -> Kind<F, A> {
        return value.flatMap { option in option.fold(constant(defaultValue), F.pure) }
    }
}

// MARK: Instance of `EquatableK` for `OptionT`
extension OptionTPartial: EquatableK where F: EquatableK {
    public static func eq<A>(_ lhs: Kind<OptionTPartial<F>, A>, _ rhs: Kind<OptionTPartial<F>, A>) -> Bool where A : Equatable {
        return OptionT.fix(lhs).value == OptionT.fix(rhs).value
    }
}

// MARK: Instance of `Invariant` for `OptionT`
extension OptionTPartial: Invariant where F: Functor {}

// MARK: Instance of `Functor` for `OptionT`
extension OptionTPartial: Functor where F: Functor {
    public static func map<A, B>(_ fa: Kind<OptionTPartial<F>, A>, _ f: @escaping (A) -> B) -> Kind<OptionTPartial<F>, B> {
        let ota = OptionT.fix(fa)
        return OptionT(ota.value.map { a in Option.fix(a.map(f)) })
    }
}

// MARK: Instance of `FunctorFilter` for `OptionT`
extension OptionTPartial: FunctorFilter where F: Functor {
    public static func mapFilter<A, B>(_ fa: Kind<OptionTPartial<F>, A>, _ f: @escaping (A) -> Kind<ForOption, B>) -> Kind<OptionTPartial<F>, B> {
        let ota = OptionT.fix(fa)
        return OptionT(ota.value.map { option in Option.fix(option.flatMap(f)) })
    }
}

// MARK: Instance of `Applicative` for `OptionT`
extension OptionTPartial: Applicative where F: Applicative {
    public static func pure<A>(_ a: A) -> Kind<OptionTPartial<F>, A> {
        return OptionT(F.pure(.some(a)))
    }

    public static func ap<A, B>(_ ff: Kind<OptionTPartial<F>, (A) -> B>, _ fa: Kind<OptionTPartial<F>, A>) -> Kind<OptionTPartial<F>, B> {
        let otf = OptionT.fix(ff)
        let ota = OptionT.fix(fa)
        return OptionT(F.map(otf.value, ota.value) { of, oa in Option.fix(of.ap(oa)) })
    }
}

// MARK: Instance of `Selective` for `OptionT`
extension OptionTPartial: Selective where F: Monad {}

// MARK: Instance of `Monad` for `OptionT`
extension OptionTPartial: Monad where F: Monad {
    public static func flatMap<A, B>(_ fa: Kind<OptionTPartial<F>, A>, _ f: @escaping (A) -> Kind<OptionTPartial<F>, B>) -> Kind<OptionTPartial<F>, B> {
        let ota = OptionT.fix(fa)
        return OptionT(ota.value.flatMap { option in
            option.fold({ F.pure(Option<B>.none()) },
                        { a in OptionT.fix(f(a)).value })
        })
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<OptionTPartial<F>, Either<A, B>>) -> Kind<OptionTPartial<F>, B> {
        return OptionT(F.tailRecM(a, { aa in
            OptionT.fix(f(aa)).value.map { option in
                option.fold({ Either.right(Option.none())},
                            { either in Either.fix(either.map(Option.some)) })
            }
        }))
    }
}

// MARK: Instance of `SemigroupK` for `OptionT`
extension OptionTPartial: SemigroupK where F: Monad {
    public static func combineK<A>(_ x: Kind<OptionTPartial<F>, A>, _ y: Kind<OptionTPartial<F>, A>) -> Kind<OptionTPartial<F>, A> {
        return OptionT.fix(x).orElse(OptionT.fix(y))
    }
}

// MARK: Instance of `MonoidK` for `OptionT`
extension OptionTPartial: MonoidK where F: Monad {
    public static func emptyK<A>() -> Kind<OptionTPartial<F>, A> {
        return OptionT(F.pure(.none()))
    }
}

// MARK: Instance of `ApplicativeError` for `OptionT`
extension OptionTPartial: ApplicativeError where F: ApplicativeError {
    public typealias E = F.E
    
    public static func raiseError<A>(_ e: F.E) -> Kind<OptionTPartial<F>, A> {
        return OptionT(F.raiseError(e))
    }
    
    public static func handleErrorWith<A>(_ fa: Kind<OptionTPartial<F>, A>, _ f: @escaping (F.E) -> Kind<OptionTPartial<F>, A>) -> Kind<OptionTPartial<F>, A> {
        return OptionT(fa^.value.handleErrorWith { e in f(e)^.value })
    }
}

// MARK: Instance of `MonadError` for `OptionT`
extension OptionTPartial: MonadError where F: MonadError {}

// MARK: Instance of `Foldable` for `OptionT`
extension OptionTPartial: Foldable where F: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<OptionTPartial<F>, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa^.value.foldLeft(b, { bb, option in option.foldLeft(bb, f) })
    }
    
    public static func foldRight<A, B>(_ fa: Kind<OptionTPartial<F>, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa^.value.foldRight(b, { option, bb in option.foldRight(bb, f) })
    }
}

// MARK: Instance of `Traverse` for `OptionT`
extension OptionTPartial: Traverse where F: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<OptionTPartial<F>, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<OptionTPartial<F>, B>> {
        return fa^.value.traverse { option in option.traverse(f) }.map { x in OptionT(x.map { b in b^ }) }
    }
}

// MARK: Instance of `TraverseFilter` for `OptionT`
extension OptionTPartial: TraverseFilter where F: TraverseFilter {
    public static func traverseFilter<A, B, G: Applicative>(_ fa: Kind<OptionTPartial<F>, A>, _ f: @escaping (A) -> Kind<G, Kind<ForOption, B>>) -> Kind<G, Kind<OptionTPartial<F>, B>> {
        return fa^.value.traverseFilter { option in option.traverseFilter(f) }.map { x in OptionT(x.map(Option.some)) }
    }
}
