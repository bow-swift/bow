import Foundation

/// Witness for the `OptionT<F, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForOptionT {}

/// Partial application of the OptionT type constructor, omitting the last parameter.
public final class OptionTPartial<F>: Kind<ForOptionT, F> {}

/// Higher Kinded Type alias to improve readability over `Kind<OptionTPartial<F>, A>`
public typealias OptionTOf<F, A> = Kind<OptionTPartial<F>, A>

/// The OptionT transformer represents the nesting of an `Option` value inside any other effect. It is equivalent to `Kind<F, Option<A>>`.
public final class OptionT<F, A>: OptionTOf<F, A> {
    fileprivate let value: Kind<F, Option<A>>

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to OptionT.
    public static func fix(_ fa: OptionTOf<F, A>) -> OptionT<F, A> {
        fa as! OptionT<F, A>
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
public postfix func ^<F, A>(_ fa: OptionTOf<F, A>) -> OptionT<F, A> {
    OptionT.fix(fa)
}

// MARK: Functions for OptionT when the effect has an instance of Functor
extension OptionT where F: Functor {
    /// Applies the provided closures based on the content of the nested `Option` value.
    ///
    /// - Parameters:
    ///   - ifEmpty: Closure to apply if the contained value in the nested `Option` is absent.
    ///   - f: Closure to apply if the contained value in the nested `Option` is present.
    /// - Returns: Result of applying the corresponding closure to the nested `Option`, wrapped in the effect.
    public func fold<B>(_ ifEmpty: @escaping () -> B, _ f: @escaping (A) -> B) -> Kind<F, B> {
        value.map { option in option.fold(ifEmpty, f) }
    }

    /// Applies the provided closures based on the content of the nested `Option` value.
    ///
    /// - Parameters:
    ///   - ifEmpty: Closure to apply if the contained value in the nested `Option` is absent.
    ///   - f: Closure to apply if the contained value in the nested `Option` is present.
    /// - Returns: Result of applying the corresponding closure to the nested `Option`, wrapped in the effect.
    public func cata<B>(_ ifEmpty: @autoclosure @escaping () -> B, _ f: @escaping (A) -> B) -> Kind<F, B> {
        fold(ifEmpty, f)
    }

    /// Lifts a value by wrapping the contained value in the effect into an `Option.some` value.
    ///
    /// - Parameter fb: Value to be lifted.
    /// - Returns: A present `Option` wrapped in the effect.
    public static func liftF(_ fb: Kind<F, A>) -> OptionT<F, A> {
        OptionT(fb.map(Option.some))
    }

    /// Obtains the value of the nested `Option` or a default value, wrapped in the effect.
    ///
    /// - Parameter defaultValue: Value for the absent case in the nested `Option`.
    /// - Returns: Value contained in the nested `Option` if present, or the default value otherwise, wrapped in the effect.
    public func getOrElse(_ defaultValue: A) -> Kind<F, A> {
        value.map { option in option.getOrElse(defaultValue) }
    }

    /// Checks if the nested `Option` is present.
    public var isDefined: Kind<F, Bool> {
        value.map { option in option.isDefined }
    }

    /// Transforms the nested `Option`.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: An `OptionT` where the nested `Option` has been transformed using the provided function.
    public func transform<B>(_ f: @escaping (Option<A>) -> Option<B>) -> OptionT<F, B> {
        OptionT<F, B>(value.map(f))
    }
    
    /// Transforms the wrapped value.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: An OptionT where the wrapped value has been transformed using the provided function.
    public func transformT<G, B>(_ f: @escaping (Kind<F, Option<A>>) -> Kind<G, Option<B>>) -> OptionT<G, B> {
        OptionT<G, B>(f(self.value))
    }

    /// Flatmaps the provided function to the nested `Option`.
    ///
    /// - Parameter f: Function for the flatmap operation.
    /// - Returns: Result of flatmapping the provided function to the nested `Option`, wrapped in the effect.
    public func subflatMap<B>(_ f: @escaping (A) -> Option<B>) -> OptionT<F, B> {
        transform { option in option.flatMap(f)^ }
    }

    /// Convert this `OptionT` to an `EitherT`.
    ///
    /// - Parameter defaultRight: Function returning a default value to use as right if the `OptionT` is none.
    /// - Returns: An `EitherT` containing the value as left or as right with the default value if the `OptionT` contains a none.
    public func toLeft<R>(_ defaultRight: @escaping () -> R) -> EitherT<F, A, R> {
        EitherT(cata(.right(defaultRight()), Either.left))
    }

    /// Convenience `toLeft` allowing a constant as the parameter.
    ///
    /// - Parameter defaultRight: Function returning a default value to use as right if the `OptionT` is none.
    /// - Returns: An `EitherT` containing the value as left or as right with the default value if the `OptionT` contains a none.
    public func toLeft<R>(_ defaultRight: @autoclosure @escaping () -> R) -> EitherT<F, A, R> {
        toLeft(defaultRight)
    }

    /// Convert this `OptionT` to an `EitherT`.
    ///
    /// - Parameter defaultLeft: Function returning a default value to use as left if the `OptionT` is none.
    /// - Returns: Returns: An `EitherT` containing the value as right or as left with the default value if the `OptionT` contains a none.
    public func toRight<L>(_ defaultLeft: @escaping () -> L) -> EitherT<F, L, A> {
        EitherT(cata(.left(defaultLeft()), Either.right))
    }

    /// Convenience `toRight` allowing a constant as the parameter.
    ///
    /// - Parameter defaultLeft: Function returning a default value to use as left if the `OptionT` is none.
    /// - Returns: Returns: An `EitherT` containing the value as right or as left with the default value if the `OptionT` contains a none.
    public func toRight<L>(_ defaultLeft: @autoclosure @escaping () -> L) -> EitherT<F, L, A> {
        EitherT(cata(.left(defaultLeft()), Either.right))
    }
}

// MARK: Functions for OptionT when the effect has an instance of Applicative
extension OptionT where F: Applicative {
    /// Constructs an `OptionT` with a nested empty `Option`.
    ///
    /// - Returns: An `OptionT` with a nested empty `Option`.
    public static func none() -> OptionT<F, A> {
        OptionT(F.pure(.none()))
    }

    /// Constructs an `OptionT` with a nested present `Option`.
    ///
    /// - Parameter a: Value to be wrapped in the nested `Option`.
    /// - Returns: An `OptionT` with a nested present `Option`.
    public static func some(_ a: A) -> OptionT<F, A> {
        OptionT(F.pure(.some(a)))
    }

    /// Constructs an `OptionT` from an `Option`.
    ///
    /// - Parameter option: An `Option` value.
    /// - Returns: An `OptionT` wrapping the passed argument.
    public static func fromOption(_ option: Option<A>) -> OptionT<F, A> {
        OptionT(F.pure(option))
    }
}

// MARK: Functions for OptionT when the effect has an instance of Monad
extension OptionT where F: Monad {
    /// Obtains this value if the value contained in the nested option is present, or a default value if it is absent.
    ///
    /// - Parameter defaultValue: Default value to return when the nested option is empty.
    /// - Returns: This `OptionT` if the nested option is present, or the default value otherwise.
    public func orElse(_ defaultValue: OptionT<F, A>) -> OptionT<F, A> {
        orElseF(defaultValue.value)
    }

    /// Obtains this value if the value contained in the nested option is present, or a default value if it is absent.
    ///
    /// - Parameter defaultValue: Default value to return when the nested option is empty.
    /// - Returns: This `OptionT` if the nested option is present, or the default value otherwise.
    public func orElseF(_ defaultValue: Kind<F, Option<A>>) -> OptionT<F, A> {
        OptionT<F, A>(value.flatMap { option in
            option.fold(constant(defaultValue),
                        constant(F.pure(option))) })
    }

    /// Flatmaps a function that produces an effect and lifts if back to `OptionT`.
    ///
    /// - Parameter f: A function producing an effect.
    /// - Returns: Result of flatmapping and lifting the function to this value.
    public func semiflatMap<B>(_ f: @escaping (A) -> Kind<F, B>) -> OptionT<F, B> {
        self.flatMap { option in OptionT<F, B>.liftF(f(option)) }^
    }

    /// Obtains the value contained in the nested `Option` if present, or a default value otherwise.
    ///
    /// - Parameter defaultValue: Default value to return when the nested option is empty.
    /// - Returns: The value in the nested option wrapped in the effect if it is present, or the default value otherwise.
    public func getOrElseF(_ defaultValue: Kind<F, A>) -> Kind<F, A> {
        value.flatMap { option in option.fold(constant(defaultValue), F.pure) }
    }
}

// MARK: Instance of EquatableK for OptionT
extension OptionTPartial: EquatableK where F: EquatableK {
    public static func eq<A: Equatable>(
        _ lhs: OptionTOf<F, A>,
        _ rhs: OptionTOf<F, A>) -> Bool {
        lhs^.value == rhs^.value
    }
}

// MARK: Instance of Invariant for OptionT
extension OptionTPartial: Invariant where F: Functor {}

// MARK: Instance of Functor for OptionT
extension OptionTPartial: Functor where F: Functor {
    public static func map<A, B>(
        _ fa: OptionTOf<F, A>,
        _ f: @escaping (A) -> B) -> OptionTOf<F, B> {
        OptionT(fa^.value.map { a in a.map(f)^ })
    }
}

// MARK: Instance of FunctorFilter for OptionT
extension OptionTPartial: FunctorFilter where F: Functor {
    public static func mapFilter<A, B>(
        _ fa: OptionTOf<F, A>,
        _ f: @escaping (A) -> OptionOf<B>) -> OptionTOf<F, B> {
        OptionT(fa^.value.map { option in option.flatMap(f)^ })
    }
}

// MARK: Instance of Applicative for OptionT
extension OptionTPartial: Applicative where F: Applicative {
    public static func pure<A>(_ a: A) -> OptionTOf<F, A> {
        OptionT(F.pure(.some(a)))
    }

    public static func ap<A, B>(
        _ ff: OptionTOf<F, (A) -> B>,
        _ fa: OptionTOf<F, A>) -> OptionTOf<F, B> {
        OptionT(F.map(ff^.value, fa^.value) { of, oa in
            of.ap(oa)^
        })
    }
}

// MARK: Instance of Selective for OptionT
extension OptionTPartial: Selective where F: Monad {}

// MARK: Instance of Monad for OptionT
extension OptionTPartial: Monad where F: Monad {
    public static func flatMap<A, B>(
        _ fa: OptionTOf<F, A>,
        _ f: @escaping (A) -> OptionTOf<F, B>) -> OptionTOf<F, B> {
        OptionT(fa^.value.flatMap { option in
            option.fold({ F.pure(Option<B>.none()) },
                        { a in f(a)^.value })
        })
    }

    public static func tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> OptionTOf<F, Either<A, B>>) -> OptionTOf<F, B> {
        OptionT(F.tailRecM(a, { aa in
            f(aa)^.value.map { option in
                option.fold({ Either.right(Option.none())},
                            { either in either.map(Option.some)^ })
            }
        }))
    }
}

// MARK: Instance of SemigroupK for OptionT
extension OptionTPartial: SemigroupK where F: Monad {
    public static func combineK<A>(
        _ x: OptionTOf<F, A>,
        _ y: OptionTOf<F, A>) -> OptionTOf<F, A> {
        x^.orElse(y^)
    }
}

// MARK: Instance of MonoidK for OptionT
extension OptionTPartial: MonoidK where F: Monad {
    public static func emptyK<A>() -> OptionTOf<F, A> {
        OptionT(F.pure(.none()))
    }
}

// MARK: Instance of ApplicativeError for OptionT
extension OptionTPartial: ApplicativeError where F: ApplicativeError {
    public typealias E = F.E
    
    public static func raiseError<A>(_ e: F.E) -> OptionTOf<F, A> {
        OptionT(F.raiseError(e))
    }
    
    public static func handleErrorWith<A>(
        _ fa: OptionTOf<F, A>,
        _ f: @escaping (F.E) -> OptionTOf<F, A>) -> OptionTOf<F, A> {
        OptionT(fa^.value.handleErrorWith { e in f(e)^.value })
    }
}

// MARK: Instance of MonadError for OptionT
extension OptionTPartial: MonadError where F: MonadError {}

// MARK: Instance of Foldable for OptionT
extension OptionTPartial: Foldable where F: Foldable {
    public static func foldLeft<A, B>(
        _ fa: OptionTOf<F, A>,
        _ b: B,
        _ f: @escaping (B, A) -> B) -> B {
        fa^.value.foldLeft(b, { bb, option in option.foldLeft(bb, f) })
    }
    
    public static func foldRight<A, B>(
        _ fa: OptionTOf<F, A>,
        _ b: Eval<B>,
        _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        fa^.value.foldRight(b, { option, bb in option.foldRight(bb, f) })
    }
}

// MARK: Instance of Traverse for OptionT
extension OptionTPartial: Traverse where F: Traverse {
    public static func traverse<G: Applicative, A, B>(
        _ fa: OptionTOf<F, A>,
        _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, OptionTOf<F, B>> {
        fa^.value.traverse { option in option.traverse(f) }
            .map { x in OptionT(x.map { b in b^ }) }
    }
}

// MARK: Instance of TraverseFilter for OptionT
extension OptionTPartial: TraverseFilter where F: TraverseFilter {
    public static func traverseFilter<A, B, G: Applicative>(
        _ fa: OptionTOf<F, A>,
        _ f: @escaping (A) -> Kind<G, OptionOf<B>>) -> Kind<G, OptionTOf<F, B>> {
        fa^.value.traverseFilter { option in option.traverseFilter(f) }
            .map { x in OptionT(x.map(Option.some)) }
    }
}

// MARK: Instance of MonadReader for OptionT
extension OptionTPartial: MonadReader where F: MonadReader {
    public typealias D = F.D
    
    public static func ask() -> OptionTOf<F, F.D> {
        OptionT.liftF(F.ask())
    }
    
    public static func local<A>(
        _ fa: OptionTOf<F, A>,
        _ f: @escaping (F.D) -> F.D) -> OptionTOf<F, A> {
        fa^.transformT { a in F.local(a, f) }
    }
}

// MARK: Instance of MonadWriter for OptionT
extension OptionTPartial: MonadWriter where F: MonadWriter {
    public typealias W = F.W
    
    public static func writer<A>(_ aw: (F.W, A)) -> OptionTOf<F, A> {
        OptionT.liftF(F.writer(aw))
    }
    
    public static func listen<A>(_ fa: OptionTOf<F, A>) -> OptionTOf<F, (F.W, A)> {
        fa^.transformT { a in
            F.listen(a).map { result in
                let (w, option) = result
                return option.map { a in (w, a) }^
            }
        }
    }
    
    public static func pass<A>(_ fa: OptionTOf<F, ((F.W) -> F.W, A)>) -> OptionTOf<F, A> {
        fa^.transformT { a in
            F.pass(a.map { option in
                option.fold({ (id, Option.none()) },
                            { x in (x.0, Option.some(x.1)) })
            })
        }
    }
}

// MARK: Instance of MonadState for OptionT

extension OptionTPartial: MonadState where F: MonadState {
    public typealias S = F.S
    
    public static func get() -> OptionTOf<F, F.S> {
        OptionT.liftF(F.get())
    }
    
    public static func set(_ s: F.S) -> OptionTOf<F, Void> {
        OptionT.liftF(F.set(s))
    }
}
