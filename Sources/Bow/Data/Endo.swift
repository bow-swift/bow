/// Witness for the `Endo<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForEndo {}

/// Partial application of the Endo type constructor, omitting the last type parameter.
public typealias EndoPartial = ForEndo

/// Higher Kinded Type alias to improve readability over `Kind<ForEndo, A>`.
public typealias EndoOf<A> = Kind<ForEndo, A>

///  Endo represents an Endomorphism; i.e., a function where the input and output type is the same.
public final class Endo<A>: EndoOf<A> {
    /// Underlying function describing the endomorphism.
    public let run: (A) -> A
    
    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to Endo.
    public static func fix(_ fa: EndoOf<A>) -> Endo<A> {
        fa as! Endo<A>
    }
    
    /// Initializes an endomorphism from a plain Swift function.
    /// - Parameter run: Function describing the endomorphism.
    public init(_ run: @escaping (A) -> A) {
        self.run = run
    }
    
    /// Invokes this endo-function.
    ///
    /// - Parameter value: Input to the function.
    /// - Returns: Output of the function.
    public func callAsFunction(_ value: A) -> A {
        run(value)
    }
}

// MARK: Instance of `Semigroup` for `Endo`
extension Endo : Semigroup {
    public func combine(_ other: Endo<A>) -> Endo<A> {
        Endo <A> (other.run <<< self.run)
    }
}

// MARK: Instance of `Monoid` for `Endo`
extension Endo : Monoid {
    public static func empty() -> Endo<A> {
        Endo <A> (id)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Endo.
public postfix func ^<A>(_ fa: EndoOf<A>) -> Endo<A> {
    Endo.fix(fa)
}
