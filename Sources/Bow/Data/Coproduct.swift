import Foundation

/// Witness for the `Coproduct<F, G, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForCoproduct {}

/// Partial application of the Coproduct type constructor, omitting the last parameter.
public final class CoproductPartial<F, G>: Kind2<ForCoproduct, F, G> {}

/// Higher Kinded Type alias to improve readability over `Kind<CoproductPartial<F, G>, A>`.
public typealias CoproductOf<F, G, A> = Kind<CoproductPartial<F, G>, A>

/// Coproduct is a sum type for kinds. Represents a type where you can hold either a `Kind<F, A>` or a `Kind<G, A>`.
public class Coproduct<F, G, A>: CoproductOf<F, G, A> {
    fileprivate let run: Either<Kind<F, A>, Kind<G, A>>
    
    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to Coproduct.
    public static func fix(_ fa: CoproductOf<F, G, A>) -> Coproduct<F, G, A> {
        return fa as! Coproduct<F, G, A>
    }
    
    /// Initializes a Coproduct from an Either.
    ///
    /// - Parameter run: Either value to initialize this Coproduct.
    public init(_ run: Either<Kind<F, A>, Kind<G, A>>) {
        self.run = run
    }

    /// Initializes a Coproduct from a value of the left type.
    ///
    /// - Parameter fa: Value of the left type.
    public init(_ fa: Kind<F, A>) {
        self.run = .left(fa)
    }

    /// Initializes a Coproduct from a value of the right type.
    ///
    /// - Parameter ga: Value of the right type.
    public init(_ ga: Kind<G, A>) {
        self.run = .right(ga)
    }

    /// Applies the provided `FunctionK` based on the content of this `Coproduct` value.
    ///
    /// - Parameters:
    ///   - f: Function to apply if the contained value in this `Coproduct` is a member of the left type.
    ///   - g: Function to apply if the contained value in this `Coproduct` is a member of the right type.
    /// - Returns: Result of applying the corresponding function to this value.
    public func fold<H>(_ f: FunctionK<F, H>, _ g: FunctionK<G, H>) -> Kind<H, A> {
        return run.fold({ fa in f.invoke(fa) }, { ga in g.invoke(ga) })
    }
}

// MARK: Instance of `EquatableK` for `Coproduct`.
extension CoproductPartial: EquatableK where F: EquatableK, G: EquatableK {
    public static func eq<A>(_ lhs: Kind<CoproductPartial<F, G>, A>, _ rhs: Kind<CoproductPartial<F, G>, A>) -> Bool where A : Equatable {
        return Coproduct.fix(lhs).run == Coproduct.fix(rhs).run
    }
}

// MARK: Instance of `Invariant` for `Coproduct`.
extension CoproductPartial: Invariant where F: Functor, G: Functor {}

// MARK: Instance of `Functor` for `Coproduct`.
extension CoproductPartial: Functor where F: Functor, G: Functor {
    public static func map<A, B>(_ fa: Kind<CoproductPartial<F, G>, A>, _ f: @escaping (A) -> B) -> Kind<CoproductPartial<F, G>, B> {
        let cop = Coproduct<F, G, A>.fix(fa)
        return Coproduct(cop.run.bimap({ fa in fa.map(f) },
                                       { ga in ga.map(f) }))
    }
}

// MARK: Instance of `Comonad` for `Coproduct`.
extension CoproductPartial: Comonad where F: Comonad, G: Comonad {
    public static func coflatMap<A, B>(_ fa: Kind<CoproductPartial<F, G>, A>, _ f: @escaping (Kind<CoproductPartial<F, G>, A>) -> B) -> Kind<CoproductPartial<F, G>, B> {
        let cop = Coproduct<F, G, A>.fix(fa)
        return Coproduct(cop.run.bimap(
            { fa in fa.coflatMap { a in f(Coproduct(Either.left(a))) } },
            { ga in ga.coflatMap { a in f(Coproduct(Either.right(a))) } }))
    }

    public static func extract<A>(_ fa: Kind<CoproductPartial<F, G>, A>) -> A {
        let cop = Coproduct<F, G, A>.fix(fa)
        return cop.run.fold({ fa in fa.extract() },
                            { ga in ga.extract() })
    }
}

// MARK: Instance of `Foldable` for `Coproduct`.
extension CoproductPartial: Foldable where F: Foldable, G: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<CoproductPartial<F, G>, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        let cop = Coproduct<F, G, A>.fix(fa)
        return cop.run.fold(
            { fa in fa.foldLeft(b, f) },
            { ga in ga.foldLeft(b, f) })
    }

    public static func foldRight<A, B>(_ fa: Kind<CoproductPartial<F, G>, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        let cop = Coproduct<F, G, A>.fix(fa)
        return cop.run.fold(
            { fa in fa.foldRight(b, f) },
            { ga in ga.foldRight(b, f) })
    }
}

// MARK: Instance of `Traverse` for `Coproduct`.
extension CoproductPartial: Traverse where F: Traverse, G: Traverse {
    public static func traverse<H: Applicative, A, B>(_ fa: Kind<CoproductPartial<F, G>, A>, _ f: @escaping (A) -> Kind<H, B>) -> Kind<H, Kind<CoproductPartial<F, G>, B>> {
        let cop = Coproduct<F, G, A>.fix(fa)
        return cop.run.fold(
            { fa in H.map(fa.traverse(f), { fb in Coproduct(Either.left(fb)) })},
            { ga in H.map(ga.traverse(f), { gb in Coproduct(Either.right(gb)) })})
    }
}
