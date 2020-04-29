import Foundation

/// Witness for the `Function0<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForFunction0 {}

/// Partial application of the Function0 type constructor, omitting the last type parameter.
public typealias Function0Partial = ForFunction0

/// Higher Kinded Type alias to improve readability of `Kind<ForFunction0, A>`.
public typealias Function0Of<A> = Kind<ForFunction0, A>

/// This data type acts as a wrapper over functions that receive no input and produce a value; namely, constant functions. This wrapper gives these functions capabilities to be used as a Higher Kinded Type and conform to typeclasses that have this requirement.
public final class Function0<A>: Function0Of<A> {
    fileprivate let f: () -> A
    
    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to `Function0`.
    public static func fix(_ fa: Function0Of<A>) -> Function0<A> {
        fa as! Function0
    }
    
    /// Constructs a value of `Function0`.
    ///
    /// - Parameter f: A constant function.
    public init(_ f: @escaping () -> A) {
        self.f = f
    }
    
    /// Invokes the function.
    ///
    /// - Returns: Value produced by this function.
    public func invoke() -> A {
        f()
    }
    
    /// Invokes the function.
    ///
    /// - Returns: Value produced by this function.
    public func callAsFunction() -> A {
        f()
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in the higher-kind form.
/// - Returns: Value cast to `Function0`.
public postfix func ^<A>(_ fa: Function0Of<A>) -> Function0<A> {
    Function0.fix(fa)
}

// MARK: Instance of EquatableK for Function0
extension Function0Partial: EquatableK {
    public static func eq<A: Equatable>(
        _ lhs: Function0Of<A>,
        _ rhs: Function0Of<A>) -> Bool {
        lhs^.extract() == rhs^.extract()
    }
}

// MARK: Instance of Functor for Function0
extension Function0Partial: Functor {
    public static func map<A, B>(
        _ fa: Function0Of<A>,
        _ f: @escaping (A) -> B) -> Function0Of<B> {
        Function0(fa^.f >>> f)
    }
}

// MARK: Instance of Applicative for Function0
extension Function0Partial: Applicative {
    public static func pure<A>(_ a: A) -> Function0Of<A> {
        Function0(constant(a))
    }
}

// MARK: Instance of Selective for Function0
extension Function0Partial: Selective {}

// MARK: Instance of Monad for Function0
extension Function0Partial: Monad {
    public static func flatMap<A, B>(_ fa: Function0Of<A>, _ f: @escaping (A) -> Function0Of<B>) -> Function0Of<B> {
        f(fa^.f())
    }

    private static func loop<A, B>(_ a: A, _ f: @escaping (A) -> Function0Of<Either<A, B>>) -> Trampoline<B> {
        .defer {
            f(a)^.extract().fold({ a in loop(a, f) },
                                 { b in .done(b) })
        }
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Function0Of<Either<A, B>>) -> Function0Of<B> {
        Function0<B>({ loop(a, f).run() })
    }
}

// MARK: Instance of Comonad for Function0
extension Function0Partial: Comonad {
    public static func coflatMap<A, B>(_ fa: Function0Of<A>, _ f: @escaping (Function0Of<A>) -> B) -> Function0Of<B> {
        Function0<B> { f(fa^) }
    }

    public static func extract<A>(_ fa: Function0Of<A>) -> A {
        fa^.f()
    }
}

// MARK: Instance of Bimonad for Function0
extension Function0Partial: Bimonad {}

// MARK: Instance of Semigroup for Function0
extension Function0: Semigroup where A: Semigroup {
    public func combine(_ other: Function0<A>) -> Function0<A> {
        Function0 { self.invoke().combine(other.invoke()) }
    }
}

// MARK: Instance of Monoid for Function0
extension Function0: Monoid where A: Monoid {
    public static func empty() -> Function0<A> {
        Function0(constant(A.empty()))
    }
}
