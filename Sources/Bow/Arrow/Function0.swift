import Foundation

/// Witness for the `Function0<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForFunction0 {}

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
        return fa as! Function0
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
        return f()
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in the higher-kind form.
/// - Returns: Value cast to `Function0`.
public postfix func ^<A>(_ fa: Function0Of<A>) -> Function0<A> {
    return Function0.fix(fa)
}

// MARK: Protocol conformances

// MARK: Instance of `EquatableK` for `Function0`
extension ForFunction0: EquatableK {
    public static func eq<A>(_ lhs: Kind<ForFunction0, A>, _ rhs: Kind<ForFunction0, A>) -> Bool where A : Equatable {
        return Function0.fix(lhs).extract() == Function0.fix(rhs).extract()
    }
}

// MARK: Instance of `Functor` for `Function0`
extension ForFunction0: Functor {
    public static func map<A, B>(_ fa: Kind<ForFunction0, A>, _ f: @escaping (A) -> B) -> Kind<ForFunction0, B> {
        return Function0(Function0.fix(fa).f >>> f)
    }
}

// MARK: Instance of `Applicative` for `Function0`
extension ForFunction0: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForFunction0, A> {
        return Function0(constant(a))
    }
}

// MARK: Instance of `Selective` for `Function0`
extension ForFunction0: Selective {}

// MARK: Instance of `Monad` for `Function0`
extension ForFunction0: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ForFunction0, A>, _ f: @escaping (A) -> Kind<ForFunction0, B>) -> Kind<ForFunction0, B> {
        return f(Function0.fix(fa).f())
    }

    private static func loop<A, B>(_ a: A, _ f: (A) -> Function0Of<Either<A, B>>) -> B {
        let result = Function0.fix(f(a)).extract()
        return result.fold({ a in loop(a, f) }, id)
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForFunction0, Either<A, B>>) -> Kind<ForFunction0, B> {
        return Function0<B>({ loop(a, f) })
    }
}

// MARK: Instance of `Comonad` for `Function0`
extension ForFunction0: Comonad {
    public static func coflatMap<A, B>(_ fa: Kind<ForFunction0, A>, _ f: @escaping (Kind<ForFunction0, A>) -> B) -> Kind<ForFunction0, B> {
        return Function0<B>({ f(Function0.fix(fa)) })
    }

    public static func extract<A>(_ fa: Kind<ForFunction0, A>) -> A {
        return Function0.fix(fa).f()
    }
}

// MARK: Instance of `Bimonad` for `Function0`
extension ForFunction0: Bimonad {}

// MARK: Instance of `Semigroup` for `Function0`
extension Function0: Semigroup where A: Semigroup {
    public func combine(_ other: Function0<A>) -> Function0<A> {
        return Function0 { self.invoke().combine(other.invoke()) }
    }
}

// MARK: Instance of `Monoid` for `Function0`
extension Function0: Monoid where A: Monoid {
    public static func empty() -> Function0<A> {
        return Function0(constant(A.empty()))
    }
}
