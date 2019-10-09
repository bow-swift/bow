import Foundation

/// Witness for the `Kleisli<F, D, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForKleisli {}

/// Partial application of the Kleisli type constructor, omitting the last parameter.
public final class KleisliPartial<F, D>: Kind2<ForKleisli, F, D> {}

/// Higher Kinded Type alias to improve readability over `Kind<KleisliPartial<F, D>, A>`.
public typealias KleisliOf<F, D, A> = Kind<KleisliPartial<F, D>, A>

/// Alias over `Kleisli<F, D, A>`.
public typealias ReaderT<F, D, A> = Kleisli<F, D, A>

/// Kleisli represents a function with the signature `(D) -> Kind<F, A>`.
public final class Kleisli<F, D, A>: KleisliOf<F, D, A> {
    internal let run: (D) -> Kind<F, A>
    
    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to Kleisli.
    public static func fix(_ fa: KleisliOf<F, D, A>) -> Kleisli<F, D, A> {
        return fa as! Kleisli<F, D, A>
    }
    
    /// Creates a constant Kleisli function.
    ///
    /// - Parameter fa: Constant value to return.
    /// - Returns: A constant Kleisli function.
    public static func liftF(_ fa: Kind<F, A>) -> Kleisli<F, D, A> {
        return Kleisli(constant(fa))
    }
    
    /// Initializes a Kleisli value.
    ///
    /// - Parameter run: Closure to be wrapped in this Kleisli.
    public init(_ run: @escaping (D) -> Kind<F, A>) {
        self.run = run
    }

    /// Inkoves this Kleisli function with an input value.
    ///
    /// - Parameter value: Input to the function.
    /// - Returns: Output of the Kleisli.
    public func invoke(_ value: D) -> Kind<F, A> {
        return run(value)
    }
    
    /// Pre-composes this Kleisli function with a function transforming the input type.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: Composition of the two functions.
    public func contramap<DD>(_ f: @escaping (DD) -> D) -> Kleisli<F, DD, A> {
        return Kleisli<F, DD, A> { d in self.invoke(f(d)) }
    }
    
    /// Pre-composes this Kleisli function with a function transforming the input type obtained from a key path.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: Composition of the two functions.
    public func contramap<DD>(_ keyPath: KeyPath<DD, D>) -> Kleisli<F, DD, A> {
        return Kleisli<F, DD, A> { d in self.invoke(d[keyPath: keyPath]) }
    }
    
    /// Narrows the scope of the context of this Kleisli from `Any` to a concrete type
    ///
    /// - Returns: A copy of this Kleisli working on a more precise context.
    func narrow<DD>() -> Kleisli<F, DD, A> where D == Any {
        self.contramap(id)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Kleisli.
public postfix func ^<F, D, A>(_ fa: KleisliOf<F, D, A>) -> Kleisli<F, D, A> {
    return Kleisli.fix(fa)
}

// MARK: Functions when F has an instance of `Monad`.
extension Kleisli where F: Monad {
    /// Zips this Kleisli function with another one with the same input type.
    ///
    /// - Parameter o: Kleisli function to be zipped with this one.
    /// - Returns: A Kleisli function that pairs the output of the two Kleisli functions zipped in this operation.
    public func zip<B>(_ o: Kleisli<F, D, B>) -> Kleisli<F, D, (A, B)> {
        return Kleisli<F, D, (A, B)>.fix(self.flatMap({ a in
            Kleisli<F, D, (A, B)>.fix(o.map({ b in (a, b) }))
        }))
    }

    /// Composes this Kleisli with another one.
    ///
    /// - Parameter f: Kleisli function to be composed after the this one.
    /// - Returns: A Kleisli function that is equivalent to running this Kleisli and then the received one.
    public func andThen<C>(_ f: Kleisli<F, A, C>) -> Kleisli<F, D, C> {
        return andThen(f.run)
    }

    /// Composes this Kleisli with a function in Kleisli form.
    ///
    /// - Parameter f: A function to be composed after this Kleisli.
    /// - Returns: A Kleisli function that is equivalent to running this Kleisli and then the received one.
    public func andThen<B>(_ f: @escaping (A) -> Kind<F, B>) -> Kleisli<F, D, B> {
        return Kleisli<F, D, B>({ d in self.run(d).flatMap(f) })
    }

    /// Composes this Kleisli with a constant value.
    ///
    /// - Parameter a: Constant value.
    /// - Returns: A Kleisli function that is equivalent to running this Kleisli and ommitting its result, returning the constant value produced.
    public func andThen<B>(_ a: Kind<F, B>) -> Kleisli<F, D, B> {
        return andThen(constant(a))
    }
}

// MARK: Instance of `EquatableK` for `Kleisli`
extension KleisliPartial: EquatableK where F: EquatableK, D == Int {
    public static func eq<A>(_ lhs: Kind<KleisliPartial<F, D>, A>, _ rhs: Kind<KleisliPartial<F, D>, A>) -> Bool where A : Equatable {
        return Kleisli.fix(lhs).invoke(1) == Kleisli.fix(rhs).invoke(1)
    }
}

// MARK: Instance of `Invariant` for `Kleisli`
extension KleisliPartial: Invariant where F: Functor {}

// MARK: Instance of `Functor` for `Kleisli`
extension KleisliPartial: Functor where F: Functor {
    public static func map<A, B>(_ fa: Kind<KleisliPartial<F, D>, A>, _ f: @escaping (A) -> B) -> Kind<KleisliPartial<F, D>, B> {
        return Kleisli<F, D, B>({ d in Kleisli.fix(fa).run(d).map(f) })
    }
}

// MARK: Instance of `Applicative` for `Kleisli`
extension KleisliPartial: Applicative where F: Applicative {
    public static func pure<A>(_ a: A) -> Kind<KleisliPartial<F, D>, A> {
        return Kleisli(constant(F.pure(a)))
    }

    public static func ap<A, B>(_ ff: Kind<KleisliPartial<F, D>, (A) -> B>, _ fa: Kind<KleisliPartial<F, D>, A>) -> Kind<KleisliPartial<F, D>, B> {
        return Kleisli<F, D, B>({ d in Kleisli.fix(ff).run(d).ap(Kleisli.fix(fa).run(d)) })
    }
}

// MARK: Instance of `Selective` for `Kleisli`
extension KleisliPartial: Selective where F: Monad {}

// MARK: Instance of `Monad` for `Kleisli`
extension KleisliPartial: Monad where F: Monad {
    public static func flatMap<A, B>(_ fa: Kind<KleisliPartial<F, D>, A>, _ f: @escaping (A) -> Kind<KleisliPartial<F, D>, B>) -> Kind<KleisliPartial<F, D>, B> {
        return Kleisli<F, D, B>({ d in Kleisli.fix(fa).run(d).flatMap { a in Kleisli.fix(f(a)).run(d) } })
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<KleisliPartial<F, D>, Either<A, B>>) -> Kind<KleisliPartial<F, D>, B> {
        return Kleisli({ b in F.tailRecM(a, { a in Kleisli.fix(f(a)).run(b) })})
    }
}

// MARK: Instance of `MonadReader` for `Kleisli`
extension KleisliPartial: MonadReader where F: Monad {
    public static func ask() -> Kind<KleisliPartial<F, D>, D> {
        return Kleisli<F, D, D>(F.pure)
    }

    public static func local<A>(_ fa: Kind<KleisliPartial<F, D>, A>, _ f: @escaping (D) -> D) -> Kind<KleisliPartial<F, D>, A> {
        return Kleisli({ dd in Kleisli.fix(fa).run(f(dd)) })
    }
}

// MARK: Instance of `ApplicativeError` for `Kleisli`
extension KleisliPartial: ApplicativeError where F: ApplicativeError {
    public typealias E = F.E

    public static func raiseError<A>(_ e: F.E) -> Kind<KleisliPartial<F, D>, A> {
        return Kleisli(constant(F.raiseError(e)))
    }

    public static func handleErrorWith<A>(_ fa: Kind<KleisliPartial<F, D>, A>, _ f: @escaping (F.E) -> Kind<KleisliPartial<F, D>, A>) -> Kind<KleisliPartial<F, D>, A> {
        return Kleisli<F, D, A>({ d in Kleisli.fix(fa).run(d).handleErrorWith { e in Kleisli.fix(f(e)).run(d) } })
    }
}

// MARK: Instance of `MonadError` for `Kleisli`
extension KleisliPartial: MonadError where F: MonadError {}
