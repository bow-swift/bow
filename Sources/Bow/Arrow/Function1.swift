import Foundation

/// Witness for the `Function1<I, O>` data type. To be used in simulated Higher Kinded Types`.
public final class ForFunction1 {}

/// Partial application of the `Function1` type constructor, omitting the last parameter.
public final class Function1Partial<I>: Kind<ForFunction1, I> {}

/// Higher Kinded Type alias to improve readability of `Kind<Function1Partial<I>, O>`.
public typealias Function1Of<I, O> = Kind<Function1Partial<I>, O>

/// This data type acts as a wrapper over functions. It receives two type parameters representing the input and output type of the function. The wrapper adds capabilities to use a function as a Higher Kinded Type and conform to typeclasses that have this requirement.
public class Function1<I, O>: Function1Of<I, O> {
    fileprivate let f: (I) -> O
    
    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to `Function1`.
    public static func fix(_ fa: Function1Of<I, O>) -> Function1<I, O> {
        return fa as! Function1<I, O>
    }
    
    /// Constructs a value of `Function1`.
    ///
    /// - Parameter f: Function to be wrapped in this Higher Kinded Type.
    public init(_ f: @escaping (I) -> O) {
        self.f = f
    }
    
    /// Invokes this function.
    ///
    /// - Parameter value: Input to the function.
    /// - Returns: Result of invoking the function.
    public func invoke(_ value: I) -> O {
        return f(value)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in the higher-kind form.
/// - Returns: Value cast to `Function1`.
public postfix func ^<I, O>(_ fa: Function1Of<I, O>) -> Function1<I, O> {
    return Function1.fix(fa)
}

// MARK: Protocol conformances

extension Function1Partial: Functor {
    public static func map<A, B>(_ fa: Kind<Function1Partial<I>, A>, _ f: @escaping (A) -> B) -> Kind<Function1Partial<I>, B> {
        return Function1(Function1.fix(fa).f >>> f)
    }
}

extension Function1Partial: Applicative {
    public static func pure<A>(_ a: A) -> Kind<Function1Partial<I>, A> {
        return Function1(constant(a))
    }
}

extension Function1Partial: Monad {
    public static func flatMap<A, B>(_ fa: Kind<Function1Partial<I>, A>, _ f: @escaping (A) -> Kind<Function1Partial<I>, B>) -> Kind<Function1Partial<I>, B> {
        return Function1<I, B>({ i in Function1.fix(f(Function1.fix(fa).f(i))).f(i) })
    }

    private static func step<A, B>(_ a: A, _ t: I, _ f: (A) -> Function1Of<I, Either<A, B>>) -> B {
        return Function1.fix(f(a)).f(t).fold({ a in step(a, t, f) }, id)
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<Function1Partial<I>, Either<A, B>>) -> Kind<Function1Partial<I>, B> {
        return Function1<I, B>({ t in step(a, t, f) })
    }
}

extension Function1Partial: MonadReader {
    public typealias D = I

    public static func ask() -> Kind<Function1Partial<I>, I> {
        return Function1(id)
    }

    public static func local<A>(_ fa: Kind<Function1Partial<I>, A>, _ f: @escaping (I) -> I) -> Kind<Function1Partial<I>, A> {
        return Function1(f >>> Function1.fix(fa).f)
    }
}
