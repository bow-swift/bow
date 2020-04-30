import Foundation

/// Witness for the `Kleisli<F, D, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForKleisli {}

/// Partial application of the Kleisli type constructor, omitting the last parameter.
public final class KleisliPartial<F, D>: Kind2<ForKleisli, F, D> {}

/// Higher Kinded Type alias to improve readability over `Kind<KleisliPartial<F, D>, A>`.
public typealias KleisliOf<F, D, A> = Kind<KleisliPartial<F, D>, A>

/// Alias over `Kleisli<F, D, A>`.
public typealias ReaderT<F, D, A> = Kleisli<F, D, A>

/// Alias over `KleisliPartial<F, D>`
public typealias ReaderTPartial<F, D> = KleisliPartial<F, D>

/// Kleisli represents a function with the signature `(D) -> Kind<F, A>`.
public final class Kleisli<F, D, A>: KleisliOf<F, D, A> {
    internal let f: (D) -> Kind<F, A>
    
    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to Kleisli.
    public static func fix(_ fa: KleisliOf<F, D, A>) -> Kleisli<F, D, A> {
        fa as! Kleisli<F, D, A>
    }
    
    /// Creates a constant Kleisli function.
    ///
    /// - Parameter fa: Constant value to return.
    /// - Returns: A constant Kleisli function.
    public static func liftF(_ fa: Kind<F, A>) -> Kleisli<F, D, A> {
        Kleisli(constant(fa))
    }
    
    /// Initializes a Kleisli value.
    ///
    /// - Parameter run: Closure to be wrapped in this Kleisli.
    public init(_ f: @escaping (D) -> Kind<F, A>) {
        self.f = f
    }

    /// Inkoves this Kleisli function with an input value.
    ///
    /// - Parameter value: Input to the function.
    /// - Returns: Output of the Kleisli.
    public func run(_ value: D) -> Kind<F, A> {
        f(value)
    }
    
    /// Inkoves this Kleisli function with an input value.
    ///
    /// - Parameter value: Input to the function.
    /// - Returns: Output of the Kleisli.
    public func callAsFunction(_ value: D) -> Kind<F, A> {
        f(value)
    }
    
    /// Pre-composes this Kleisli function with a function transforming the input type.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: Composition of the two functions.
    public func contramap<DD>(_ f: @escaping (DD) -> D) -> Kleisli<F, DD, A> {
        Kleisli<F, DD, A> { d in self.run(f(d)) }
    }
    
    /// Narrows the scope of the context of this Kleisli from `Any` to a concrete type
    ///
    /// - Returns: A copy of this Kleisli working on a more precise context.
    public func narrow<DD>() -> Kleisli<F, DD, A> where D == Any {
        self.contramap(id)
    }
    
    /// Transforms the result of this Kleisli function.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: A Kleisli function that behaves as the original one, with its result transformed.
    public func transformT<G, B>(_ f: @escaping (Kind<F, A>) -> Kind<G, B>) -> Kleisli<G, D, B> {
        Kleisli<G, D, B>(self.f >>> f)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Kleisli.
public postfix func ^<F, D, A>(_ fa: KleisliOf<F, D, A>) -> Kleisli<F, D, A> {
    Kleisli.fix(fa)
}

// MARK: Functions when F has an instance of Monad.
extension Kleisli where F: Monad {
    /// Accesses the environment to produce a pure value.
    ///
    /// - Parameter f: Function accessing the environment.
    /// - Returns: A Kleisli function wrapping the produced value.
    public static func access(_ f: @escaping (D) -> A) -> Kleisli<F, D, A> {
        accessM(f >>> pure >>> fix)
    }
    
    /// Accesses the environment to produce a Kleisli effect.
    ///
    /// - Parameter f: Function accessing the environment.
    /// - Returns: A Kleisli function wraping the produced value.
    public static func accessM(_ f: @escaping (D) -> Kleisli<F, D, A>) -> Kleisli<F, D, A> {
        Kleisli<F, D, D>.ask().flatMap(f)^
    }
    
    /// Zips this Kleisli function with another one with the same input type.
    ///
    /// - Parameter o: Kleisli function to be zipped with this one.
    /// - Returns: A Kleisli function that pairs the output of the two Kleisli functions zipped in this operation.
    public func zip<B>(_ o: Kleisli<F, D, B>) -> Kleisli<F, D, (A, B)> {
        self.flatMap { a in
            o.map { b in (a, b) }^
        }^
    }

    /// Composes this Kleisli with another one.
    ///
    /// - Parameter f: Kleisli function to be composed after the this one.
    /// - Returns: A Kleisli function that is equivalent to running this Kleisli and then the received one.
    public func andThen<C>(_ f: Kleisli<F, A, C>) -> Kleisli<F, D, C> {
        andThen(f.f)
    }

    /// Composes this Kleisli with a function in Kleisli form.
    ///
    /// - Parameter f: A function to be composed after this Kleisli.
    /// - Returns: A Kleisli function that is equivalent to running this Kleisli and then the received one.
    public func andThen<B>(_ f: @escaping (A) -> Kind<F, B>) -> Kleisli<F, D, B> {
        Kleisli<F, D, B> { d in self.f(d).flatMap(f) }
    }

    /// Composes this Kleisli with a constant value.
    ///
    /// - Parameter fb: Constant value.
    /// - Returns: A Kleisli function that is equivalent to running this Kleisli and ommitting its result, returning the constant value produced.
    public func andThen<B>(_ fb: Kind<F, B>) -> Kleisli<F, D, B> {
        andThen(constant(fb))
    }
}

// MARK: Functions when F has an instance of Monad.
extension Kleisli where F: MonadError {
    /// Folds over the result of this computation by accepting a function to execute in case of error, and another one in the case of success.
    ///
    /// - Parameters:
    ///   - f: Function to run in case of error.
    ///   - g: Function to run in case of success.
    /// - Returns: A computation from the result of applying the provided functions to the result of this computation.
    public func foldA<B>(
        _ f: @escaping (F.E) -> B,
        _ g: @escaping (A) -> B
    ) -> Kleisli<F, D, B> {
        foldM(f >>> Kleisli<F, D, B>.pure >>> Kleisli<F, D, B>.fix,
              g >>> Kleisli<F, D, B>.pure >>> Kleisli<F, D, B>.fix)
    }
    
    /// Folds over the result of this computation by accepting an effect to execute in case of error, and another one in the case of success.
    ///
    /// - Parameters:
    ///   - f: Function to run in case of error.
    ///   - g: Function to run in case of success.
    /// - Returns: A computation from the result of applying the provided functions to the result of this computation.
    public func foldM<B>(
        _ f: @escaping (F.E) -> Kleisli<F, D, B>,
        _ g: @escaping (A) -> Kleisli<F, D, B>) -> Kleisli<F, D, B> {
        self.flatMap(g).handleErrorWith(f)^
    }
}

// MARK: Instance of Invariant for Kleisli
extension KleisliPartial: Invariant where F: Functor {}

// MARK: Instance of Functor for Kleisli
extension KleisliPartial: Functor where F: Functor {
    public static func map<A, B>(
        _ fa: KleisliOf<F, D, A>,
        _ f: @escaping (A) -> B) -> KleisliOf<F, D, B> {
        Kleisli<F, D, B> { d in fa^.f(d).map(f) }
    }
}

// MARK: Instance of Applicative for Kleisli
extension KleisliPartial: Applicative where F: Applicative {
    public static func pure<A>(_ a: A) -> KleisliOf<F, D, A> {
        Kleisli(constant(F.pure(a)))
    }

    public static func ap<A, B>(
        _ ff: KleisliOf<F, D, (A) -> B>,
        _ fa: KleisliOf<F, D, A>) -> KleisliOf<F, D, B> {
        Kleisli<F, D, B>({ d in ff^.f(d).ap(fa^.f(d)) })
    }
}

// MARK: Instance of Selective for Kleisli
extension KleisliPartial: Selective where F: Monad {}

// MARK: Instance of Monad for Kleisli
extension KleisliPartial: Monad where F: Monad {
    public static func flatMap<A, B>(
        _ fa: KleisliOf<F, D, A>,
        _ f: @escaping (A) -> KleisliOf<F, D, B>) -> KleisliOf<F, D, B> {
        Kleisli<F, D, B> { d in
            fa^.f(d).flatMap { a in
                f(a)^.f(d)
            }
        }
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> KleisliOf<F, D, Either<A, B>>) -> KleisliOf<F, D, B> {
        Kleisli { b in F.tailRecM(a, { a in f(a)^.f(b) }) }
    }
}

// MARK: Instance of MonadReader for Kleisli
extension KleisliPartial: MonadReader where F: Monad {
    public static func ask() -> KleisliOf<F, D, D> {
        Kleisli<F, D, D>(F.pure)
    }

    public static func local<A>(_ fa: KleisliOf<F, D, A>, _ f: @escaping (D) -> D) -> KleisliOf<F, D, A> {
        Kleisli { dd in fa^.f(f(dd)) }
    }
}

// MARK: Instance of ApplicativeError for Kleisli
extension KleisliPartial: ApplicativeError where F: ApplicativeError {
    public typealias E = F.E

    public static func raiseError<A>(_ e: F.E) -> KleisliOf<F, D, A> {
        Kleisli(constant(F.raiseError(e)))
    }

    public static func handleErrorWith<A>(
        _ fa: KleisliOf<F, D, A>,
        _ f: @escaping (F.E) -> KleisliOf<F, D, A>) -> KleisliOf<F, D, A> {
        Kleisli<F, D, A> { d in
            fa^.f(d).handleErrorWith { e in
                f(e)^.f(d)
            }
        }
    }
}

// MARK: Instance of MonadError for Kleisli
extension KleisliPartial: MonadError where F: MonadError {}

// MARK: Instance of MonadWriter for Kleisli
extension KleisliPartial: MonadWriter where F: MonadWriter {
    public typealias W = F.W
    
    public static func writer<A>(_ aw: (F.W, A)) -> KleisliOf<F, D, A> {
        Kleisli.liftF(F.writer(aw))
    }
    
    public static func listen<A>(_ fa: KleisliOf<F, D, A>) -> KleisliOf<F, D, (F.W, A)> {
        fa^.transformT { a in F.listen(a) }
    }
    
    public static func pass<A>(_ fa: KleisliOf<F, D, ((F.W) -> F.W, A)>) -> KleisliOf<F, D, A> {
        fa^.transformT { a in F.pass(a) }
    }
}

// MARK: Instance of MonadState for Kleisli

extension KleisliPartial: MonadState where F: MonadState {
    public typealias S = F.S
    
    public static func get() -> KleisliOf<F, D, F.S> {
        Kleisli.liftF(F.get())
    }
    
    public static func set(_ s: F.S) -> KleisliOf<F, D, Void> {
        Kleisli.liftF(F.set(s))
    }
}
