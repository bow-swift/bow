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
    public static func fix(_ fa: CokleisliOf<F, A, B>) -> Cokleisli<F, A, B> {
        fa as! Cokleisli<F, A, B>
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
        Cokleisli<F, C, B> { fc in self.run(f(fc)) }
    }
    
    /// Invokes this function.
    ///
    /// - Parameter value: Input to the function.
    /// - Returns: Output of the function.
    public func callAsFunction(_ value: Kind<F, A>) -> B {
        run(value)
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Cokleisli.
public postfix func ^<F, A, B>(_ value: CokleisliOf<F, A, B>) -> Cokleisli<F, A, B> {
    Cokleisli.fix(value)
}

// MARK: Functions for Cokleisli when the effect has a Comonad instance.
extension Cokleisli where F: Comonad {
    /// Creates a Cokleisli that extracts the value of a `Comonad`.
    ///
    /// - Returns: A Cokleisli that extracts the value of a `Comonad`.
    public static func ask() -> Cokleisli<F, B, B> {
        Cokleisli<F, B, B> { fb in fb.extract() }
    }

    /// Transforms the type arguments of this Cokleisli.
    ///
    /// - Parameters:
    ///   - g: Function to transform the input type argument.
    ///   - f: Function to transform the output type argument.
    /// - Returns: A Cokleisli with both type arguments transformed.
    public func bimap<C, D>(
        _ g: @escaping (D) -> A,
        _ f: @escaping (B) -> C) -> Cokleisli<F, D, C> {
        Cokleisli<F, D, C> { fa in f(self.run(fa.map(g))) }
    }

    /// Transforms the input type argument of this Cokleisli.
    ///
    /// - Parameter g: Function to transform the input type argument.
    /// - Returns: A Cokleisli with both type arguments transformed.
    public func lmap<D>(_ g: @escaping (D) -> A) -> Cokleisli<F, D, B> {
        Cokleisli<F, D, B> { fa in self.run(fa.map(g)) }
    }

    /// Composes this Cokleisli with another one.
    ///
    /// - Parameter a: Cokleisli to compose with this value.
    /// - Returns: Composition of both Cokleisli values.
    public func compose<D>(_ a: Cokleisli<F, D, A>) -> Cokleisli<F, D, B> {
        Cokleisli<F, D, B> { fa in self.run(fa.coflatMap(a.run)) }
    }

    /// Composes this Cokleisli with an effect, discarding the result produced by this Cokleisli.
    ///
    /// - Parameter a: An effect.
    /// - Returns: Composition of this Cokleisli with an effect.
    public func andThen<C>(_ a: Kind<F, C>) -> Cokleisli<F, A, C> {
        Cokleisli<F, A, C> { _ in a.extract() }
    }

    /// Composes this Cokleisli with another one.
    ///
    /// - Parameter a: Cokleisli to compose with this value.
    /// - Returns: Composition of both Cokleisli values.
    public func andThen<C>(_ a: Cokleisli<F, B, C>) -> Cokleisli<F, A, C>  {
        a.compose(self)
    }
}

// MARK: Instance of Functor for Cokleisli
extension CokleisliPartial: Functor {
    public static func map<A, B>(
        _ fa: CokleisliOf<F, I, A>,
        _ f: @escaping (A) -> B) -> CokleisliOf<F, I, B> {
        Cokleisli(fa^.run >>> f)
    }
}
