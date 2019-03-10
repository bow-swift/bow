import Foundation

/// Witness for the `Id<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForId {}

/// Higher Kinded Type alias to improve readability of `Kind<ForId, A>`.
public typealias IdOf<A> = Kind<ForId, A>

/// The identity data type represents a context of having no effect on the type it wraps. A instance of `Id<A>` is isomorphic to an instance of `A`; it is just wrapped without any additional information.
public class Id<A>: IdOf<A> {
    public let value: A

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to `Id`.
    public static func fix(_ fa: IdOf<A>) -> Id<A> {
        return fa as! Id<A>
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
    return Id.fix(fa)
}

// MARK: Protocol conformances
/// Conformance of `Id` to `CustomStringConvertible`.
extension Id: CustomStringConvertible {
    public var description: String {
        return "Id(\(value))"
    }
}

/// Conformance of `Id` to `CustomDebugStringConvertible`, given that type parameter also conforms to `CustomDebugStringConvertible`.
extension Id: CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Id(\(value.debugDescription))"
    }
}

/// Conformance of `Id` to `Equatable`, given that type parameter also conforms to `Equatable`.
extension ForId: EquatableK {
    public static func eq<A>(_ lhs: Kind<ForId, A>, _ rhs: Kind<ForId, A>) -> Bool where A : Equatable {
        return Id.fix(lhs).value == Id.fix(rhs).value
    }
}

extension ForId: Functor {
    public static func map<A, B>(_ fa: Kind<ForId, A>, _ f: @escaping (A) -> B) -> Kind<ForId, B> {
        return Id(f(Id.fix(fa).value))
    }
}

extension ForId: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForId, A> {
        return Id(a)
    }
}

extension ForId: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ForId, A>, _ f: @escaping (A) -> Kind<ForId, B>) -> Kind<ForId, B> {
        let id = Id<A>.fix(fa)
        return f(id.value)
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForId, Either<A, B>>) -> Kind<ForId, B> {
        return Id<Either<A, B>>.fix(f(a)).value
            .fold({ left in tailRecM(left, f)},
                  Id<B>.pure)
    }
}

extension ForId: Comonad {
    public static func coflatMap<A, B>(_ fa: Kind<ForId, A>, _ f: @escaping (Kind<ForId, A>) -> B) -> Kind<ForId, B> {
        return fa.map{ _ in f(fa) }
    }

    public static func extract<A>(_ fa: Kind<ForId, A>) -> A {
        return Id.fix(fa).value
    }
}

extension ForId: Bimonad {}

extension ForId: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ForId, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        let id = Id<A>.fix(fa)
        return f(b, id.value)
    }

    public static func foldRight<A, B>(_ fa: Kind<ForId, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        let id = Id<A>.fix(fa)
        return f(id.value, b)
    }
}

extension ForId: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<ForId, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<ForId, B>> {
        let id = Id<A>.fix(fa)
        return G.map(f(id.value), Id<B>.init)
    }
}
