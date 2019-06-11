import Foundation

/// Witness for the `Cokleisli<F, A, B>` data type. To be used in simulated Higher Kinded Types.
public final class ForCokleisli {}

/// Partial application of the Cokleisli type constructor, omitting the last parameter.
public final class CokleisliPartial<F, I>: Kind2<ForCokleisli, F, I> {}

/// Higher Kinded Type alias to improve readability over `Kind<CokleisliPartial<F, A>, B>`.
public typealias CokleisliOf<F, A, B> = Kind<CokleisliPartial<F, A>, B>

/// Alias over `Cokleisli<F, A, B>`.
public typealias CoreaderT<F, A, B> = Cokleisli<F, A, B>

/// Cokleisli represents a function with the signature `(Kind<F, A>) -> B`.
public class Cokleisli<F, A, B>: CokleisliOf<F, A, B> {
    public let run: (Kind<F, A>) -> B

    /// Safe downcast.
    ///
    /// - Parameter value: Value in higher-kind form.
    /// - Returns: Value cast to Cokleisli.
    public static func fix(_ fa: Kind<CokleisliPartial<F, A>, B>) -> Cokleisli<F, A, B> {
        return fa as! Cokleisli<F, A, B>
    }
    
    /// Initializes a Cokleisli.
    ///
    /// - Parameter run: Closure to be wrapped in this Cokleisli.
    public init(_ run: @escaping (Kind<F, A>) -> B) {
        self.run = run
    }
    
    /// Composes the internal function with another function.
    ///
    /// - Parameter f: Function to compose with the internal function.
    /// - Returns: A Cokleisli with the result of the composition.
    public func contramapValue<C>(_ f: @escaping (Kind<F, C>) -> Kind<F, A>) -> Cokleisli<F, C, B> {
        return Cokleisli<F, C, B>({ fc in self.run(f(fc)) })
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Cokleisli.
public postfix func ^<F, A, B>(_ value: Kind<CokleisliPartial<F, A>, B>) -> Cokleisli<F, A, B> {
    return Cokleisli.fix(value)
}

// MARK: Functions for `Cokleisli` when the effect has a `Comonad` instance.
extension Cokleisli where F: Comonad {
    /// Creates a Cokleisli that extracts the value of a `Comonad`.
    ///
    /// - Returns: A Cokleisli that extracts the value of a `Comonad`.
    public static func ask() -> Cokleisli<F, B, B> {
        return Cokleisli<F, B, B>({ fb in fb.extract() })
    }

    /// Transforms the type arguments of this Cokleisli.
    ///
    /// - Parameters:
    ///   - g: Function to transform the input type argument.
    ///   - f: Function to transform the output type argument.
    /// - Returns: A Cokleisli with both type arguments transformed.
    public func bimap<C, D>(_ g: @escaping (D) -> A, _ f : @escaping (B) -> C) -> Cokleisli<F, D, C> {
        return Cokleisli<F, D, C>({ fa in f(self.run(fa.map(g))) })
    }

    /// Transforms the input type argument of this Cokleisli.
    ///
    /// - Parameter g: Function to transform the input type argument.
    /// - Returns: A Cokleisli with both type arguments transformed.
    public func lmap<D>(_ g: @escaping (D) -> A) -> Cokleisli<F, D, B> {
        return Cokleisli<F, D, B>({ fa in self.run(fa.map(g)) })
    }

    /// Composes this Cokleisli with another one.
    ///
    /// - Parameter a: Cokleisli to compose with this value.
    /// - Returns: Composition of both Cokleisli values.
    public func compose<D>(_ a: Cokleisli<F, D, A>) -> Cokleisli<F, D, B> {
        return Cokleisli<F, D, B>({ fa in self.run(fa.coflatMap(a.run)) })
    }

    /// Composes this Cokleisli with an effect, discarding the result produced by this Cokleisli.
    ///
    /// - Parameter a: An effect.
    /// - Returns: Composition of this Cokleisli with an effect.
    public func andThen<C>(_ a: Kind<F, C>) -> Cokleisli<F, A, C> {
        return Cokleisli<F, A, C>({ _ in a.extract() })
    }

    /// Composes this Cokleisli with another one.
    ///
    /// - Parameter a: Cokleisli to compose with this value.
    /// - Returns: Composition of both Cokleisli values.
    public func andThen<C>(_ a: Cokleisli<F, B, C>) -> Cokleisli<F, A, C>  {
        return a.compose(self)
    }
}

// MARK: Instance of `Functor` for `Cokleisli`
extension CokleisliPartial: Functor {
    public static func map<A, B>(_ fa: Kind<CokleisliPartial<F, I>, A>, _ f: @escaping (A) -> B) -> Kind<CokleisliPartial<F, I>, B> {
        return Cokleisli(Cokleisli.fix(fa).run >>> f)
    }
}

// MARK: Instance of `Applicative` for `Cokleisli`
extension CokleisliPartial: Applicative {
    public static func pure<A>(_ a: A) -> Kind<CokleisliPartial<F, I>, A> {
        return Cokleisli({ _ in a })
    }
}

// MARK: Instance of `Selective` for `Cokleisli`
extension CokleisliPartial: Selective {}

// MARK: Instance of `Monad` for `Cokleisli`
extension CokleisliPartial: Monad {
    public static func flatMap<A, B>(_ fa: Kind<CokleisliPartial<F, I>, A>, _ f: @escaping (A) -> Kind<CokleisliPartial<F, I>, B>) -> Kind<CokleisliPartial<F, I>, B> {
        let cok = Cokleisli.fix(fa)
        return Cokleisli({ x in Cokleisli.fix(f(cok.run(x))).run(x) })
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<CokleisliPartial<F, I>, Either<A, B>>) -> Kind<CokleisliPartial<F, I>, B> {
        fatalError("Not implemented yet")
    }
}

