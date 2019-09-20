import Foundation

/// Witness for the `WriterT<F, W, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForWriterT {}

/// Partial application of the WriterT type constructor, omitting the last parameter.
public final class WriterTPartial<F, W>: Kind2<ForWriterT, F, W> {}

/// Higher Kinded Type alias to improve readability over `Kind<WriterTPartial<F, W>, A>`.
public typealias WriterTOf<F, W, A> = Kind<WriterTPartial<F, W>, A>

/// Partial application of the Writer type constructor, omitting the last parameter.
public typealias WriterPartial<W> = WriterTPartial<ForId, W>

/// Higher Kinded Type alias to improve readability over `Kind<WriterTPartial<ForId, W>, A>`.
public typealias WriterOf<W, A> = WriterTOf<ForId, W, A>

/// Writer is a WriterT where the effect is `Id`.
public typealias Writer<W, A> = WriterT<ForId, W, A>

/// WriterT transformer represents operations that accumulate values through a computation or effect, without reading them.
public final class WriterT<F, W, A>: WriterTOf<F, W, A> {
    fileprivate let value: Kind<F, (W, A)>

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to WriterT.
    public static func fix(_ fa: WriterTOf<F, W, A>) -> WriterT<F, W, A> {
        return fa as! WriterT<F, W, A>
    }
    
    /// Initializes a `WriterT`.
    ///
    /// - Parameter value: A pair of accumulator and value wrapped in an effect.
    public init(_ value: Kind<F, (W, A)>) {
        self.value = value
    }
    
    /// Provides the values wrapped in this WriterT
    public var runT: Kind<F, (W, A)> {
        return value
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to WriterT.
public postfix func ^<F, W, A>(_ fa : WriterTOf<F, W, A>) -> WriterT<F, W, A> {
    return WriterT.fix(fa)
}

// MARK: Functions for `Writer`
extension WriterT where F == ForId {
    /// Provides the values wrapped in this Writer
    public var run: (W, A) {
        return value^.value
    }
}

// MARK: Functions for `WriterT` when the effect has an instance of `Functor`
extension WriterT where F: Functor {
    /// Adds an accumulated value to an effect.
    ///
    /// - Parameters:
    ///   - fa: A value wrapped in an effect.
    ///   - w: A value for the accumulator.
    /// - Returns: A `WriterT` where the effect wraps the original value with the accumulator.
    public static func putT(_ fa: Kind<F, A>, _ w: W) -> WriterT<F, W, A> {
        return WriterT(fa.map { a in (w, a) })
    }

    /// Obtains an effect with the result value.
    ///
    /// - Returns: Effect with the result value.
    public func content() -> Kind<F, A> {
        return value.map { pair in pair.1 }
    }

    /// Obtains an effect with the accumulator value.
    ///
    /// - Returns: Effect with the accumulator value.
    public func written() -> Kind<F, W> {
        return value.map { pair in pair.0 }
    }
}

// MARK: Functions for `WriterT` when the effect has an instance of `Functor` and the accumulator type has an instance of `Monoid`
extension WriterT where F: Functor, W: Monoid {
    /// Lifts an effect to a `WriterT` using the empty value of the `Monoid` as the accumulator.
    ///
    /// - Parameter fa: An effect.
    /// - Returns: A `WriterT` where the effect wraps the original value with an empty accumulator.
    public static func valueT(_ fa: Kind<F, A>) -> WriterT<F, W, A> {
        return WriterT.putT(fa, W.empty())
    }
}

// MARK: Functions for `WriterT` when the effect has an instance of `Applicative`
extension WriterT where F: Applicative {
    /// Creates a `WriterT` from values for the result and accumulator.
    ///
    /// - Parameters:
    ///   - w: Initial value for the accumulator.
    ///   - a: Initial value for the result.
    /// - Returns: A `WriterT` wrapping the provided values in an effect.
    public static func both(_ w: W, _ a: A) -> WriterT<F, W, A> {
        return WriterT(F.pure((w, a)))
    }

    /// Creates a `WriterT` from a tuple.
    ///
    /// - Parameter z: A tuple where the first component is used for the accumulator and the second for the result value.
    /// - Returns: A `WriterT` wrapping the provided values in an effect.
    public static func fromTuple(_ z: (W, A)) -> WriterT<F, W, A> {
        return WriterT(F.pure(z))
    }

    /// Creates a `WriterT` from values for the result and accumulator.
    ///
    /// - Parameters:
    ///   - a: Initial value for the result.
    ///   - w: Initial value for the accumulator.
    /// - Returns: A `WriterT` wrapping the provided values in an effect.
    public static func put(_ a: A, _ w: W) -> WriterT<F, W, A> {
        return WriterT.putT(F.pure(a), w)
    }

    /// Creates a `WriterT` from an initial value for the accumulator.
    ///
    /// - Parameter l: Initial value for the accumulator.
    /// - Returns: A `WriterT` wrapping the provided value and unit for the result value.
    public static func tell(_ l: W) -> WriterT<F, W, Unit>  {
        return WriterT<F, W, Unit>.put(unit, l)
    }

    /// Lifts an effect using the accumulator value of this `WriterT`.
    ///
    /// - Parameter fb: Effect to be lifted.
    /// - Returns: A `WriterT` wrapping the value contained in the effect parameter and using the accumulator of this `WriterT`.
    public func liftF<B>(_ fb: Kind<F, B>) -> WriterT<F, W, B> {
        return WriterT<F, W, B>(F.map(fb, value, { x, y in (y.0, x) }))
    }
}

// MARK: Functions for `WriterT` when the effect has an instance of `Applicative` and the accumulator type has an instance of `Monoid`
extension WriterT where F: Applicative, W: Monoid {
    /// Creates a `WriterT` from an initial value for the result.
    ///
    /// - Parameter a: Initial value for the result.
    /// - Returns: A `WriterT` wrapping the provided value and using the empty value of the `Monoid` for the accumulator.
    public static func value(_ a: A) -> WriterT<F, W, A> {
        return WriterT.put(a, W.empty())
    }
}

// MARK: Functions for `WriterT` when the effect has an instance of `Monad`
extension WriterT where F: Monad {
    /// Transforms the accumulator and result values using a provided function.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: A `WriterT` where the original values have been transformed using the provided function.
    public func transform<B, U>(_ f: @escaping ((W, A)) -> (U, B)) -> WriterT<F, U, B> {
        return WriterT<F, U, B>(value.flatMap { pair in F.pure(f(pair)) })
    }

    /// Transforms the accumulator using the provided function.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: A `WriterT` with the same result as the original one, and the transformed accumulator.
    public func mapAcc<U>(_ f: @escaping (W) -> U) -> WriterT<F, U, A> {
        return transform({ pair in (f(pair.0), pair.1) })
    }

    /// Transforms the accumulator and result values using two functions.
    ///
    /// - Parameters:
    ///   - g: Transforming function for the accumulator.
    ///   - f: Transforming function for the result.
    /// - Returns: A `WriterT` where the original values have been transformed using the provided functions.
    public func bimap<B, U>(_ g: @escaping (W) -> U, _ f: @escaping (A) -> B) -> WriterT<F, U, B> {
        return transform({ pair in (g(pair.0), f(pair.1))})
    }

    /// Flatmaps the provided function to the nested tuple.
    ///
    /// - Parameter f: Function for the flatmap operation.
    /// - Returns: Result of flatmapping the provided function to the nested values, wrapped in the effect.
    public func subflatMap<B>(_ f: @escaping (A) -> (W, B)) -> WriterT<F, W, B> {
        return transform({ pair in f(pair.1) })
    }

    /// Swaps the result and accumulator values.
    ///
    /// - Returns: A `WriterT` where the accumulator is the original result value and vice versa.
    public func swap() -> WriterT<F, A, W> {
        return transform({ pair in (pair.1, pair.0) })
    }

    /// Runs this effect and pairs the result with the accumulator for a new result.
    ///
    /// - Returns: A `WriterT` where the result is paired with the accumulator.
    public func listen() -> Kind<WriterTPartial<F, W>, (W, A)> {
        return WriterT<F, W, (W, A)>(content().flatMap { a in
            self.written().map { l in
                (l, (l, a))
            }
        })
    }
}

// MARK: Functions for `WriterT` when the effect has an instance of `Monad` and the accumulator type has an instance of `Semigroup`
extension WriterT where F: Monad, W: Semigroup {
    /// Combines the accumulator with a new value.
    ///
    /// - Parameter w: New value to combine the accumulator with.
    /// - Returns: A `WriterT` with the same result and combined accumulator.
    public func tell(_ w: W) -> WriterT<F, W, A> {
        return mapAcc({ inW in inW.combine(w) })
    }
}

// MARK: Functions for `WriterT` when the effect has an instance of `Monad` and the accumulator type has an instance of `Monoid`
extension WriterT where F: Monad, W: Monoid {
    /// Flatmaps a function that produces an effect and lifts it back to `WriterT`.
    ///
    /// - Parameter f: A function producing an effect.
    /// - Returns: Result of flatmapping and lifting the function on this value.
    public func semiflatMap<B>(_ f: @escaping (A) -> Kind<F, B>) -> WriterT<F, W, B> {
        return WriterT<F, W, B>.fix(flatMap({ a in self.liftF(f(a)) }))
    }

    /// Resets the accumulator to the empty value of the `Monoid`.
    ///
    /// - Returns: A `WriterT` value with an empty accumulator and the same result value.
    public func reset() -> WriterT<F, W, A>  {
        return mapAcc(constant(W.empty()))
    }
}

// MARK: Instance of `EquatableK` for `WriterT`
extension WriterTPartial: EquatableK where F: EquatableK & Functor, W: Equatable {
    public static func eq<A>(_ lhs: Kind<WriterTPartial<F, W>, A>, _ rhs: Kind<WriterTPartial<F, W>, A>) -> Bool where A : Equatable {
        let wl0 = WriterT.fix(lhs).value.map { t in t.0 }
        let wl1 = WriterT.fix(lhs).value.map { t in t.1 }
        let wr0 = WriterT.fix(rhs).value.map { t in t.0 }
        let wr1 = WriterT.fix(rhs).value.map { t in t.1 }
        return wl0 == wr0 && wl1 == wr1
    }
}

// MARK: Instance of `Invariant` for `WriterT`
extension WriterTPartial: Invariant where F: Functor {}

// MARK: Instance of `Functor` for `WriterT`
extension WriterTPartial: Functor where F: Functor {
    public static func map<A, B>(_ fa: Kind<WriterTPartial<F, W>, A>, _ f: @escaping (A) -> B) -> Kind<WriterTPartial<F, W>, B> {
        let wa = WriterT.fix(fa)
        return WriterT(wa.value.map { pair in (pair.0, f(pair.1)) })
    }
}

// MARK: Instance of `Applicative` for `WriterT`
extension WriterTPartial: Applicative where F: Monad, W: Monoid {
    public static func pure<A>(_ a: A) -> Kind<WriterTPartial<F, W>, A> {
        return WriterT(F.pure((W.empty(), a)))
    }
}

// MARK: Instance of `Selective` for `WriterT`
extension WriterTPartial: Selective where F: Monad, W: Monoid {}

// MARK: Instance of `Monad` for `WriterT`
extension WriterTPartial: Monad where F: Monad, W: Monoid {
    public static func flatMap<A, B>(_ fa: Kind<WriterTPartial<F, W>, A>, _ f: @escaping (A) -> Kind<WriterTPartial<F, W>, B>) -> Kind<WriterTPartial<F, W>, B> {
        let wa = WriterT.fix(fa)
        return WriterT(wa.value.flatMap { pair in
            WriterT.fix(f(pair.1)).value.map { pair2 in
                (pair.0.combine(pair2.0), pair2.1)
            }
        })
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<WriterTPartial<F, W>, Either<A, B>>) -> Kind<WriterTPartial<F, W>, B> {
        return WriterT(F.tailRecM(a, { inA in
            WriterT.fix(f(inA)).value.map { pair in
                pair.1.fold(Either.left,
                            { b in Either.right((pair.0, b)) })
            }
        }))
    }
}

// MARK: Instance of `FunctorFilter` for `WriterT`
extension WriterTPartial: FunctorFilter where F: MonadFilter, W: Monoid {}

// MARK: Instance of `MonadFilter` for `WriterT`
extension WriterTPartial: MonadFilter where F: MonadFilter, W: Monoid {
    public static func empty<A>() -> Kind<WriterTPartial<F, W>, A> {
        return WriterT(F.empty())
    }
}

// MARK: Instance of `SemigroupK` for `WriterT`
extension WriterTPartial: SemigroupK where F: SemigroupK {
    public static func combineK<A>(_ x: Kind<WriterTPartial<F, W>, A>, _ y: Kind<WriterTPartial<F, W>, A>) -> Kind<WriterTPartial<F, W>, A> {
        return WriterT(WriterT.fix(x).value.combineK(WriterT.fix(y).value))
    }
}

// MARK: Instance of `MonoidK` for `WriterT`
extension WriterTPartial: MonoidK where F: MonoidK {
    public static func emptyK<A>() -> Kind<WriterTPartial<F, W>, A> {
        return WriterT(F.emptyK())
    }
}

// MARK: Instance of `MonadWriter` for `WriterT`
extension WriterTPartial: MonadWriter where F: Monad, W: Monoid {
    public static func writer<A>(_ aw: (W, A)) -> Kind<WriterTPartial<F, W>, A> {
        return WriterT.put(aw.1, aw.0)
    }

    public static func listen<A>(_ fa: Kind<WriterTPartial<F, W>, A>) -> Kind<WriterTPartial<F, W>, (W, A)> {
        return WriterT(WriterT.fix(fa).content().flatMap { a in
            WriterT.fix(fa).written().map { l in
                (l, (l, a))
            }
        })
    }

    public static func pass<A>(_ fa: Kind<WriterTPartial<F, W>, ((W) -> W, A)>) -> Kind<WriterTPartial<F, W>, A> {
        let wa = WriterT.fix(fa)
        return WriterT(wa.content().flatMap { tuple2FA in
            wa.written().map { l in
                (tuple2FA.0(l), tuple2FA.1)
            }
        })
    }
}

// MARK: Instance of `ApplicativeError` for `WriterT`
extension WriterTPartial: ApplicativeError where F: MonadError, W: Monoid {
    public typealias E = F.E
    
    public static func raiseError<A>(_ e: F.E) -> Kind<WriterTPartial<F, W>, A> {
        return WriterT(F.raiseError(e))
    }
    
    public static func handleErrorWith<A>(_ fa: Kind<WriterTPartial<F, W>, A>, _ f: @escaping (F.E) -> Kind<WriterTPartial<F, W>, A>) -> Kind<WriterTPartial<F, W>, A> {
        return WriterT(fa^.value.handleErrorWith { e in f(e)^.value })
    }
}

// MARK: Instance of `MonadError` for `WriterT`
extension WriterTPartial: MonadError where F: MonadError, W: Monoid {}
