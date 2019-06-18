import Foundation

/// Witness for the `EitherK<F, G, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForEitherK {}

/// Partial application of the EitherK type constructor, omitting the last parameter.
public final class EitherKPartial<F, G>: Kind2<ForEitherK, F, G> {}

/// Higher Kinded Type alias to improve readability over `Kind<EitherKPartial<F, G>, A>`.
public typealias EitherKOf<F, G, A> = Kind<EitherKPartial<F, G>, A>

/// EitherK is a sum type for kinds. Represents a type where you can hold either a `Kind<F, A>` or a `Kind<G, A>`.
public final class EitherK<F, G, A>: EitherKOf<F, G, A> {
    fileprivate let run: Either<Kind<F, A>, Kind<G, A>>
    
    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to EitherK.
    public static func fix(_ fa: EitherKOf<F, G, A>) -> EitherK<F, G, A> {
        return fa as! EitherK<F, G, A>
    }
    
    /// Initializes a EitherK from an Either.
    ///
    /// - Parameter run: Either value to initialize this EitherK.
    public init(_ run: Either<Kind<F, A>, Kind<G, A>>) {
        self.run = run
    }

    /// Initializes a EitherK from a value of the left type.
    ///
    /// - Parameter fa: Value of the left type.
    public init(_ fa: Kind<F, A>) {
        self.run = .left(fa)
    }

    /// Initializes a EitherK from a value of the right type.
    ///
    /// - Parameter ga: Value of the right type.
    public init(_ ga: Kind<G, A>) {
        self.run = .right(ga)
    }

    /// Applies the provided `FunctionK` based on the content of this `EitherK` value.
    ///
    /// - Parameters:
    ///   - f: Function to apply if the contained value in this `EitherK` is a member of the left type.
    ///   - g: Function to apply if the contained value in this `EitherK` is a member of the right type.
    /// - Returns: Result of applying the corresponding function to this value.
    public func fold<H>(_ f: FunctionK<F, H>, _ g: FunctionK<G, H>) -> Kind<H, A> {
        return run.fold({ fa in f.invoke(fa) }, { ga in g.invoke(ga) })
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to EitherK.
public postfix func ^<F, G, A>(_ fa: EitherKOf<F, G, A>) -> EitherK<F, G, A> {
    return EitherK.fix(fa)
}

// MARK: Instance of `EquatableK` for `EitherK`.
extension EitherKPartial: EquatableK where F: EquatableK, G: EquatableK {
    public static func eq<A>(_ lhs: Kind<EitherKPartial<F, G>, A>, _ rhs: Kind<EitherKPartial<F, G>, A>) -> Bool where A : Equatable {
        return EitherK.fix(lhs).run == EitherK.fix(rhs).run
    }
}

// MARK: Instance of `Invariant` for `EitherK`.
extension EitherKPartial: Invariant where F: Invariant, G: Invariant {
    public static func imap<A, B>(_ fa: Kind<EitherKPartial<F, G>, A>, _ f: @escaping (A) -> B, _ g: @escaping (B) -> A) -> Kind<EitherKPartial<F, G>, B> {
        return EitherK(fa^.run.bimap({ a in a.imap(f, g) }, { b in b.imap(f, g) }))
    }
}

// MARK: Instance of `Functor` for `EitherK`.
extension EitherKPartial: Functor where F: Functor, G: Functor {
    public static func map<A, B>(_ fa: Kind<EitherKPartial<F, G>, A>, _ f: @escaping (A) -> B) -> Kind<EitherKPartial<F, G>, B> {
        let cop = EitherK<F, G, A>.fix(fa)
        return EitherK(cop.run.bimap({ fa in fa.map(f) },
                                       { ga in ga.map(f) }))
    }
}

// MARK: Instance of `Comonad` for `EitherK`.
extension EitherKPartial: Comonad where F: Comonad, G: Comonad {
    public static func coflatMap<A, B>(_ fa: Kind<EitherKPartial<F, G>, A>, _ f: @escaping (Kind<EitherKPartial<F, G>, A>) -> B) -> Kind<EitherKPartial<F, G>, B> {
        let cop = EitherK<F, G, A>.fix(fa)
        return EitherK(cop.run.bimap(
            { fa in fa.coflatMap { a in f(EitherK(Either.left(a))) } },
            { ga in ga.coflatMap { a in f(EitherK(Either.right(a))) } }))
    }

    public static func extract<A>(_ fa: Kind<EitherKPartial<F, G>, A>) -> A {
        let cop = EitherK<F, G, A>.fix(fa)
        return cop.run.fold({ fa in fa.extract() },
                            { ga in ga.extract() })
    }
}

// MARK: Instance of `Foldable` for `EitherK`.
extension EitherKPartial: Foldable where F: Foldable, G: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<EitherKPartial<F, G>, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        let cop = EitherK<F, G, A>.fix(fa)
        return cop.run.fold(
            { fa in fa.foldLeft(b, f) },
            { ga in ga.foldLeft(b, f) })
    }

    public static func foldRight<A, B>(_ fa: Kind<EitherKPartial<F, G>, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        let cop = EitherK<F, G, A>.fix(fa)
        return cop.run.fold(
            { fa in fa.foldRight(b, f) },
            { ga in ga.foldRight(b, f) })
    }
}

// MARK: Instance of `Traverse` for `EitherK`.
extension EitherKPartial: Traverse where F: Traverse, G: Traverse {
    public static func traverse<H: Applicative, A, B>(_ fa: Kind<EitherKPartial<F, G>, A>, _ f: @escaping (A) -> Kind<H, B>) -> Kind<H, Kind<EitherKPartial<F, G>, B>> {
        let cop = EitherK<F, G, A>.fix(fa)
        return cop.run.fold(
            { fa in H.map(fa.traverse(f), { fb in EitherK(Either.left(fb)) })},
            { ga in H.map(ga.traverse(f), { gb in EitherK(Either.right(gb)) })})
    }
}

// MARK: Instance of `Contravariant` for `EitherK`
extension EitherKPartial: Contravariant where F: Contravariant, G: Contravariant {
    public static func contramap<A, B>(_ fa: Kind<EitherKPartial<F, G>, A>, _ f: @escaping (B) -> A) -> Kind<EitherKPartial<F, G>, B> {
        return EitherK(fa^.run.bimap({ a in a.contramap(f) }, { b in b.contramap(f) }))
    }
}
