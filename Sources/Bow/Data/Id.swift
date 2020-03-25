import Foundation

/// Witness for the `Id<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForId {}

/// Partial application of the Id type constructor, omitting the last type parameter.
public typealias IdPartial = ForId

/// Higher Kinded Type alias to improve readability of `Kind<ForId, A>`.
public typealias IdOf<A> = Kind<ForId, A>

/// The identity data type represents a context of having no effect on the type it wraps. A instance of `Id<A>` is isomorphic to an instance of `A`; it is just wrapped without any additional information.
public final class Id<A>: IdOf<A> {
    /// Value wrapped in this `Id`.
    public let value: A

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to `Id`.
    public static func fix(_ fa: IdOf<A>) -> Id<A> {
        fa as! Id<A>
    }
    
    /// Constructs a value of `Id`.
    ///
    /// - Parameter value: Value to be wrapped in `Id`.
    public init(_ value: A) {
        self.value = value
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in the higher-kind form.
/// - Returns: Value cast to `Id`.
public postfix func ^<A>(_ fa: IdOf<A>) -> Id<A> {
    Id.fix(fa)
}

// MARK: Conformance of Id to CustomStringConvertible.
extension Id: CustomStringConvertible {
    public var description: String {
        "Id(\(value))"
    }
}

// MARK: Conformance of Id to CustomDebugStringConvertible
extension Id: CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription: String {
        "Id(\(value.debugDescription))"
    }
}

// MARK: Instance of EquatableK for Id
extension IdPartial: EquatableK {
    public static func eq<A: Equatable>(
        _ lhs: IdOf<A>,
        _ rhs: IdOf<A>) -> Bool {
        lhs^.value == rhs^.value
    }
}

// MARK: Instance of Functor for Id
extension IdPartial: Functor {
    public static func map<A, B>(
        _ fa: IdOf<A>,
        _ f: @escaping (A) -> B) -> IdOf<B> {
        Id(f(fa^.value))
    }
}

// MARK: Instance of Applicative for Id
extension IdPartial: Applicative {
    public static func pure<A>(_ a: A) -> IdOf<A> {
        Id(a)
    }
}

// MARK: Instance of Selective for Id
extension IdPartial: Selective {}

// MARK: Instance of Monad for Id
extension IdPartial: Monad {
    public static func flatMap<A, B>(
        _ fa: IdOf<A>,
        _ f: @escaping (A) -> IdOf<B>) -> IdOf<B> {
        f(fa^.value)
    }

    public static func tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> IdOf<Either<A, B>>) -> IdOf<B> {
        _tailRecM(a, f).run()
    }
    
    private static func _tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> IdOf<Either<A, B>>) -> Trampoline<IdOf<B>> {
        .defer {
            f(a)^.value.fold(
                { left in _tailRecM(left, f) },
                { right in .done(Id(right)) })
        }
    }
}

// MARK: Instance of Comonad for Id
extension IdPartial: Comonad {
    public static func coflatMap<A, B>(
        _ fa: IdOf<A>,
        _ f: @escaping (IdOf<A>) -> B) -> IdOf<B> {
        fa.map { a in f(Id(a)) }
    }

    public static func extract<A>(_ fa: IdOf<A>) -> A {
        fa^.value
    }
}

// MARK: Instance of Bimonad for Id
extension IdPartial: Bimonad {}

// MARK: Instance of Foldable for Id
extension IdPartial: Foldable {
    public static func foldLeft<A, B>(
        _ fa: IdOf<A>,
        _ b: B,
        _ f: @escaping (B, A) -> B) -> B {
        f(b, fa^.value)
    }

    public static func foldRight<A, B>(
        _ fa: IdOf<A>,
        _ b: Eval<B>,
        _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        f(fa^.value, b)
    }
}

// MARK: Instance of Traverse for Id
extension IdPartial: Traverse {
    public static func traverse<G: Applicative, A, B>(
        _ fa: IdOf<A>,
        _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, IdOf<B>> {
        G.map(f(fa^.value), Id<B>.init)
    }
}

// MARK: Instance of Semigroup for Id
extension Id: Semigroup where A: Semigroup {
    public func combine(_ other: Id<A>) -> Id<A> {
        Id(self.value.combine(other.value))
    }
}

// MARK: Instance of Monoid for Id
extension Id: Monoid where A: Monoid {
    public static func empty() -> Id<A> {
        Id(A.empty())
    }
}
