import Foundation
import Bow

/// Witness for the `PSetter<S, T, A, B>` data type. To be used in simulated Higher Kinded Types.
public final class ForPSetter {}

/// Partial application of the PSetter type constructor, omitting the last parameter.
public final class PSetterPartial<S, T, A>: Kind3<ForPSetter, S, T, A> {}

/// Higher Kinded Type alias to improve readability over `Kind4<ForPSetter, S, T, A, B>`.
public typealias PSetterOf<S, T, A, B> = Kind<PSetterPartial<S, T, A>, B>

/// Setter is a type alias for `PSetter` which fixes the type arguments and restricts the `PSetter` to monomorphic updates.
public typealias Setter<S, A> = PSetter<S, S, A, A>

/// Witness for the `Setter<S, A>` data type. To be used in simulated Higher Kinded Types.
public typealias ForSetter = ForPSetter

/// Higher Kinded Type alias to improve readability over `Kind2<ForSetter, S, A>`.
public typealias SetterPartial<S> = Kind<ForSetter, S>

/// A Setter is an optic that allows to see into a structure and set or modify its focus.
///
/// A (polymorphic) PSetter is useful when setting or modifying a value for a constructed type.
///
/// A PSetter is a generalization of a `Functor`.
///
/// Parameters:
///     - `S`: Source of the PSetter.
///     - `T`: Modified source of the PSetter.
///     - `A`: Focus of the PSetter.
///     - `B`: Modified focus of the PSetter.
public class PSetter<S, T, A, B>: PSetterOf<S, T, A, B> {
    private let modifyFunc: (S, @escaping (A) -> B) -> T
    private let setFunc: (S, B) -> T
    
    /// Composes a `PSetter` with a `PSetter`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PSetter` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PSetter<S, T, A, B>, rhs: PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PSetter` with a `POptional`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PSetter` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PSetter<S, T, A, B>, rhs: POptional<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PSetter` with a `PPrism`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PSetter` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PSetter<S, T, A, B>, rhs: PPrism<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PSetter` with a `PLens`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PSetter` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PSetter<S, T, A, B>, rhs: PLens<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PSetter` with a `PIso`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PSetter` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PSetter<S, T, A, B>, rhs: PIso<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PSetter` with a `PTraversal`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PSetter` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PSetter<S, T, A, B>, rhs: PTraversal<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Creates a `PSetter` based on the instance of `Functor` of the sources.
    ///
    /// - Returns: A `PSetter` based on the instance of `Functor` of the sources.
    public static func fromFunctor<F: Functor>() -> PSetter<Kind<F, A>, Kind<F, B>, A, B> where S: Kind<F, A>, T: Kind<F, B> {
        return PSetter<Kind<F, A>, Kind<F, B>, A, B>(modify: { f in
            { fs in F.map(fs, f) }
        })
    }
    
    /// Initializes a `PSetter`.
    ///
    /// - Parameters:
    ///   - modify: Modification function.
    ///   - set: Setting function.
    public init(modify: @escaping (S, @escaping (A) -> B) -> T, set: @escaping (S, B) -> T) {
        self.modifyFunc = modify
        self.setFunc = set
    }
    
    /// Initializes a `PSetter`.
    ///
    /// - Parameter modify: Modification function.
    public init(modify: @escaping (@escaping (A) -> B) -> (S) -> T) {
        self.modifyFunc = { s, f in modify(f)(s) }
        self.setFunc = { s, b in modify(constant(b))(s) }
    }
    
    /// Modifies the source with a function to modify its focus.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Function to modify focus.
    /// - Returns: Modified source.
    public func modify(_ s: S, _ f: @escaping (A) -> B) -> T {
        return self.modifyFunc(s, f)
    }
    
    /// Sets a new focus.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - b: Modified focus.
    /// - Returns: Modified source.
    public func set(_ s: S, _ b: B) -> T {
        return self.setFunc(s, b)
    }
    
    /// Joins two `PSetter` with the same target.
    ///
    /// - Parameter other: Value to join with.
    /// - Returns: A `PSetter` that operates on either of the sources of the original `PSetter`s.
    public func choice<S1, T1>(_ other: PSetter<S1, T1, A, B>) -> PSetter<Either<S, S1>, Either<T, T1>, A, B> {
        return PSetter<Either<S, S1>, Either<T, T1>, A, B>(modify: { f in
            { either in
                either.bimap({ s in self.modify(s, f) }, { s in other.modify(s, f) })
            }
        })
    }
    
    /// Lifts a function transforming the focs into a function transforming the source.
    ///
    /// - Parameter f: Function transforming the focus.
    /// - Returns: Function transforming the source.
    public func lift(_ f: @escaping (A) -> B) -> (S) -> T {
        return { s in self.modify(s, f) }
    }
    
    /// Composes this `PSetter` with a `PSetter`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PSetter` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return PSetter<S, T, C, D>(modify: { f in
            { s in
                self.modify(s) { a in other.modify(a, f) }
            }
        })
    }
    
    /// Composes this `PSetter` with a `POptional`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PSetter` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: POptional<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.compose(other.asSetter)
    }
    
    /// Composes this `PSetter` with a `PPrism`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PSetter` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PPrism<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.compose(other.asSetter)
    }
    
    /// Composes this `PSetter` with a `PLens`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PSetter` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PLens<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.compose(other.asSetter)
    }
    
    /// Composes this `PSetter` with a `PIso`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PSetter` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PIso<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.compose(other.asSetter)
    }
    
    /// Composes this `PSetter` with a `PTraversal`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PSetter` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PTraversal<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.compose(other.asSetter)
    }
}

public extension Setter where S == A, S == T, A == B {
    /// Provides an identity `Setter`.
    static var identity: Setter<S, S> {
        return Iso<S, S>.identity.asSetter
    }
    
    /// Provides a `Setter` that takes either `S` or `S` and strips the choice of `S`.
    static var codiagonal: Setter<Either<S, S>, S> {
        return Setter<Either<S, S>, S>(modify: { f in { ss in ss.bimap(f, f) } })
    }
}

extension Setter {
    internal var fix: Setter<S, A> {
        return self as! Setter<S, A>
    }
}
