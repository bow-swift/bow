/// The Monoidal type class adds an identity element to Semigroupal type class by defining the function identity.
///
/// Identity returns a specific identity `Kind<F, A>` value for a given type F and A.
///
/// This type class complies with the following law:
/// fa.product(identity) == identity.product(fa) == identity
///
/// In addition, the laws of Semigroupal type class also apply.
///
public protocol Monoidal: Semigroupal {
    
    /// Given a type A, create a "identity" for a F<A> value
    static func identity<A>() -> Kind<Self, A>
}

// MARK: Syntax for Monoidal
public extension Kind where F: Monoidal {
    static func identity() -> Kind<F, A> {
        F.identity()
    }
}
