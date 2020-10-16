import Foundation

/// Witness for the `LazyFunction1<I, O>` data type. To be used in simulated Higher Kinded Types`.
public final class ForLazyFunction1 {}

/// Partial application of the `LazyFunction1` type constructor, omitting the last parameter.
public final class LazyFunction1Partial<I>: Kind<ForLazyFunction1, I> {}

/// Higher Kinded Type alias to improve readability of `Kind<LazyFunction1Partial<I>, O>`.
public typealias LazyFunction1Of<I, O> = Kind<LazyFunction1Partial<I>, O>

/// This data type acts as a wrapper over functions, like `Function1`.
/// As opposed to `Function1`, function composition is stack-safe.
/// This means that no matter how many `LazyFunction1`s you compose, calling their composition won't cause a stack overflow.
public final class LazyFunction1<I, O>: LazyFunction1Of<I, O> {
    private let functions: [(Any) -> Any]

    private init(_ functions: [(Any) -> Any]) {
        self.functions = functions
    }

    private var run: (I) -> O {
        { (i: I) in
            self.functions.foldLeft(i) { (x, f) in
                f(x)
            } as! O
        }
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to `LazyFunction1`.
    public static func fix(_ fa: LazyFunction1Of<I, O>) -> LazyFunction1<I, O> {
        fa as! LazyFunction1<I, O>
    }

    /// Constructs a value of `LazyFunction1`.
    ///
    /// - Parameter f: Function to be wrapped in this Higher Kinded Type.
    public init(_ f: @escaping (I) -> O) {
        functions = [erase(f)]
    }

    /// Invokes this function.
    ///
    /// - Parameter value: Input to the function.
    /// - Returns: Result of invoking the function.
    public func invoke(_ value: I) -> O {
        run(value)
    }

    /// Invokes this function.
    ///
    /// - Parameter value: Input to the function.
    /// - Returns: Result of invoking the function.
    public func callAsFunction(_ value: I) -> O {
        invoke(value)
    }

    /// Composes with another function.
    ///
    /// - Parameter f: Function to compose.
    /// - Returns: Composition of the two functions.
    public func compose<A>(_ f: LazyFunction1<A, I>) -> LazyFunction1<A, O> {
        LazyFunction1<A, O>(f.functions + functions)
    }

    /// Concatenates another function.
    ///
    /// - Parameter f: Function to concatenate.
    /// - Returns: Concatenation of the two functions.
    public func andThen<A>(_ f: LazyFunction1<O, A>) -> LazyFunction1<I, A> {
        f.compose(self)
    }

    /// Composes with another function.
    ///
    /// - Parameter f: Function to compose.
    /// - Returns: Composition of the two functions.
    public func contramap<A>(_ f: @escaping (A) -> I) -> LazyFunction1<A, O> {
        compose(LazyFunction1<A, I>(f))
    }
}

fileprivate func erase<I, O>(_ f: @escaping (I) -> O) -> (Any) -> Any {
    { f($0 as! I) }
}

/// Safe downcast.
///
/// - Parameter fa: Value in the higher-kind form.
/// - Returns: Value cast to `LazyFunction1`.
public postfix func ^<I, O>(_ fa: LazyFunction1Of<I, O>) -> LazyFunction1<I, O> {
    LazyFunction1.fix(fa)
}

// MARK: Instance of Functor for LazyFunction1
extension LazyFunction1Partial: Functor {
    public static func map<A, B>(
        _ fa: LazyFunction1Of<I, A>,
        _ f: @escaping (A) -> B) -> LazyFunction1Of<I, B> {
        fa^.andThen(LazyFunction1(f))
    }
}
